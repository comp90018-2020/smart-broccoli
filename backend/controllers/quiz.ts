import { FindOptions, Transaction } from "sequelize/types";
import ErrorStatus from "../helpers/error";
import sequelize, { Quiz, Question, UserGroup, Group, User } from "../models";
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
    quizId: number,
    original: Question[],
    updated: any[],
    transaction: Transaction
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
        await deleteQuestion(quizId, id, transaction);
    }

    let questions: Question[] = [];
    for (const question of updatedQuestions) {
        // Insert new questions (no id)
        if (!question.id) {
            questions.push(await addQuestion(quizId, question, transaction));
        }
        // If updated
        else if (originalIds.includes(question.id)) {
            questions.push(
                await updateQuestion(quizId, question.id, question, transaction)
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

    const t = await sequelize.transaction();
    try {
        await quiz.save({ transaction: t });

        // Save questions
        const quizJSON: any = {
            ...quiz.toJSON(),
            questions: (
                await processQuestions(quiz.id, [], info.questions, t)
            ).map((q) => q.toJSON()),
        };
        await t.commit();

        return quizJSON;
    } catch (err) {
        await t.rollback();
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

    const t = await sequelize.transaction();
    try {
        await quiz.save({ transaction: t });

        // Save questions
        const quizJSON: any = quiz.toJSON();
        if (info.questions) {
            const updatedQuestions = await processQuestions(
                quiz.id,
                quiz.questions,
                info.questions,
                t
            );
            quizJSON.questions = updatedQuestions.map((q) => q.toJSON());
        }
        await t.commit();
        return quizJSON;
    } catch (err) {
        await t.rollback();
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
        where: { "$Group.UserGroup.role$": isManaged ? "owner" : "member" },
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
                return { ...quiz };
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

    // Owner
    if (role === "owner") {
        return {
            ...quiz.toJSON(),
            questions: quiz.questions.map((q) => q.toJSON()),
        };
    }

    // Questions
    let questions: any = {};

    // For participants/members
    if (state === "active") {
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

    // Check whether user has priviledges
    const membership = await UserGroup.findOne({
        where: {
            userId,
            groupId: quiz.groupId,
        },
    });

    // TODO: check whether user is participant of quiz

    if (membership) {
        return { quiz, role: membership.role, state: "active" };
    }

    // TODO: quiz session
    const err = new ErrorStatus("Unimplemented", 501);
    throw err;
};

// Delete quiz
export const deleteQuiz = async (quizId: number) => {
    // Now destroy the quiz
    return await Quiz.destroy({ where: { id: quizId } });
};
