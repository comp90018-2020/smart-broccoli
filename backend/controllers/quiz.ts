import { FindOptions, Transaction } from "sequelize";
import ErrorStatus from "../helpers/error";
import sequelize, { Quiz, Question, UserGroup, User } from "../models";
import {
    checkQuestionInfo,
    addQuestion,
    deleteQuestion,
    updateQuestion,
} from "./question";
import { getGroupAndVerifyRole } from "./group";

/**
 * Processes questions of a quiz (since we don't operate on questions directly).
 * @param quizId
 * @param original Original quiz questions
 * @param updated Updated quiz questions
 */
const processQuestions = async (
    transaction: Transaction,
    quizId: number,
    original: Question[],
    updated: any[]
) => {
    // First parse updated into QuestionInfo[]
    const updatedQuestions = updated.map((q) => checkQuestionInfo(q));

    // Now get Ids
    const originalIds = original.map((q) => q.id);
    const updatedIds = updatedQuestions
        .filter((q) => q.id !== undefined)
        .map((q) => q.id);

    // Delete missing ids
    const deletedIds = originalIds.filter((id) => !updatedIds.includes(id));
    for (const id of deletedIds) {
        await deleteQuestion(transaction, quizId, id);
    }

    let questions: Question[] = [];
    for (const question of updatedQuestions) {
        // Insert new questions (no id)
        if (!question.id) {
            questions.push(await addQuestion(transaction, quizId, question));
        }
        // If updated
        else if (originalIds.includes(question.id)) {
            questions.push(
                await updateQuestion(transaction, quizId, question.id, question)
            );
        }
    }
    return questions;
};

/**
 * Create quiz.
 * @param userId ID of creator
 * @param info
 */
export const createQuiz = async (userId: number, info: any) => {
    // Ensure that creator is owner
    await getGroupAndVerifyRole(userId, info.groupId, "owner");

    // Create
    const quiz = new Quiz({
        groupId: info.groupId,
        type: info.type,
        title: info.title,
    });
    if (info.active !== undefined && info.type !== "live") {
        quiz.active = info.active;
    }
    if (info.timeLimit) {
        quiz.timeLimit = info.timeLimit;
    }
    if (info.description) {
        quiz.description = info.description;
    }

    const transaction = await sequelize.transaction();
    try {
        await quiz.save({ transaction: transaction });

        // Save questions
        const quizJSON: any = {
            ...quiz.toJSON(),
            questions: (
                await processQuestions(transaction, quiz.id, [], info.questions)
            ).map((q) => q.toJSON()),
        };
        await transaction.commit();

        return quizJSON;
    } catch (err) {
        await transaction.rollback();
        throw err;
    }
};

/**
 * Update quiz.
 * @param quizId
 * @param info
 */
export const updateQuiz = async (userId: number, quizId: number, info: any) => {
    // Get quiz
    const quiz: Quiz = await Quiz.findByPk(quizId, {
        // @ts-ignore
        include: {
            model: Question,
            as: "questions",
        },
    });

    // Ensure that creator is owner
    if (info.groupId && info.groupId !== quiz.groupId) {
        await getGroupAndVerifyRole(userId, info.groupId, "owner");
    }

    // Updates
    if (info.title) {
        quiz.title = info.title;
    }
    if (info.active !== undefined) {
        quiz.active = info.active;
    }
    if (info.type) {
        quiz.type = info.type;
    }
    // Live quizzes should be automatically active (listed)
    if (info.type === "live") {
        quiz.active = true;
    }
    if (info.groupId) {
        quiz.groupId = info.groupId;
    }
    if (info.timeLimit) {
        quiz.timeLimit = info.timeLimit;
    }
    if (info.description) {
        quiz.description = info.description;
    }

    const transaction = await sequelize.transaction();
    try {
        await quiz.save({ transaction: transaction });

        // Save questions
        const quizJSON: any = quiz.toJSON();
        if (info.questions) {
            const updatedQuestions = await processQuestions(
                transaction,
                quiz.id,
                quiz.questions,
                info.questions
            );
            quizJSON.questions = updatedQuestions.map((q) => q.toJSON());
        }
        await transaction.commit();
        return quizJSON;
    } catch (err) {
        await transaction.rollback();
        throw err;
    }
};

/**
 * Get all quiz that user has access to.
 * @param User
 */
export const getAllQuiz = async (
    user: User,
    opts: { managed?: string | boolean } = {}
) => {
    // Managed group's quizzes or as member/participant?
    const isManaged = opts.managed === true || opts.managed === "true";

    // Get quizzes of user's groups
    const groups = await user.getGroups({
        where: { "$UserGroup.role$": isManaged ? "owner" : "member" },
        include: [
            {
                // @ts-ignore
                model: Quiz,
                required: false,
                where: isManaged ? undefined : { active: true },
            },
        ],
    });

    return groups
        .map((group) => {
            return group.Quizzes.map((quiz) => {
                return quiz.toJSON();
            });
        })
        .flat();
};

/**
 * Get quiz by ID.
 * @param userId
 * @param quizId
 */
export const getQuiz = async (userId: number, quizId: number) => {
    const { quiz, role, state } = await getQuizAndRole(userId, quizId, {
        include: ["questions"],
    });

    // Questions
    let questions: any = {};

    if (role === "owner" || state === "complete") {
        // Owners, members who completed quiz
        questions = quiz.questions.map((q) => q.toJSON());
    } else if (state === "active") {
        // Quiz incomplete, but can view questions
        questions = quiz.questions.map((question) => {
            return {
                ...question.toJSON,
                tf: null,
                options: question.options.map((opt) => {
                    return {
                        ...opt,
                        correct: null,
                    };
                }),
            };
        });
    } else if (state === "complete") {
        // Quiz complete, can get answers again
        questions = quiz.questions.map((question) => question.toJSON());
    } else {
        // Haven't started quiz, no access to questions
        questions = null;
    }

    return {
        ...quiz.toJSON(),
        questions,
    };
};

/**
 * Get quiz and permissions.
 * @param userId
 * @param quizId
 * @param options FindOptions
 */
export const getQuizAndRole = async (
    userId: number,
    quizId: number,
    options?: FindOptions
) => {
    // Get quiz
    const quiz = await Quiz.findByPk(quizId, options);
    if (!quiz) {
        const err = new ErrorStatus("Quiz not found", 404);
        throw err;
    }

    // Check whether user has privileges
    const membership = await UserGroup.findOne({
        where: {
            userId,
            groupId: quiz.groupId,
        },
    });

    // Quick return if owner
    if (membership && membership.role === "owner") {
        return { quiz, role: "owner", state: null };
    }

    // TODO: check whether user is participant of quiz (state)

    // TODO: quiz session
    if (membership) {
        return { quiz, role: membership.role, state: "inactive" };
    }

    const err = new ErrorStatus("Quiz cannot be accessed", 403);
    throw err;
};

// Delete quiz
export const deleteQuiz = async (quizId: number) => {
    // Now destroy the quiz
    return await Quiz.destroy({ where: { id: quizId } });
};
