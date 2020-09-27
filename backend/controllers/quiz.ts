import { FindOptions } from "sequelize/types";
import ErrorStatus from "../helpers/error";
import { Quiz, Question, UserGroup, Group, User } from "../models";
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
        await deleteQuestion(quizId, id);
    }

    let questions: Question[] = [];
    for (const question of updatedQuestions) {
        // Insert new questions (no id)
        if (!question.id) {
            questions.push(await addQuestion(quizId, question));
        }
        // If updated
        else if (originalIds.includes(question.id)) {
            questions.push(await updateQuestion(quizId, question.id, question));
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
    if (info.timeLimit) {
        quiz.timeLimit = info.timeLimit;
    }
    if (info.description) {
        quiz.description = info.description;
    }
    await quiz.save();

    // Save questions
    const quizJSON: any = {
        ...quiz.toJSON(),
        questions: (
            await processQuestions(quiz.id, [], info.questions)
        ).map((q) => q.toJSON()),
    };
    return quizJSON;
};

/**
 * Update quiz.
 * @param quizId
 * @param info
 */
export const updateQuiz = async (userId: number, quizId: number, info: any) => {
    // Get quiz
    const quiz = await Quiz.findByPk(quizId, {
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
    if (info.type) {
        quiz.type = info.type;
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
    await quiz.save();

    // Save questions
    const quizJSON: any = quiz.toJSON();
    if (info.questions) {
        const updatedQuestions = await processQuestions(
            quiz.id,
            quiz.questions,
            info.questions
        );
        quizJSON.questions = updatedQuestions.map((q) => q.toJSON());
    }
    return quizJSON;
};

/**
 * Get all quiz that user has access to.
 * @param User
 */
export const getAllQuiz = async (user: User) => {
    // All groups and associated quiz where user is member
    // TODO: live quiz
    const groups = await user.getGroups({
        include: [
            // @ts-ignore
            { model: Quiz, required: false },
        ],
    });

    console.log(groups);
    return groups
        .map((group) => {
            return group.Quizzes.map((quiz) => {
                return { ...quiz, role: "?" };
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
    const { quiz, role } = await getQuizAndRole(userId, quizId, {
        include: ["questions"],
    });
    const quizJSON = {
        ...quiz.toJSON(),
        role,
        questions: quiz.questions.map((question) => {
            const questionJSON: any = question.toJSON();
            // If member or participant, erase answer
            if (role === "member" || role === "participant") {
                delete questionJSON["correct"];
                delete questionJSON["tf"];
            }
            return questionJSON;
        }),
    };
    return quizJSON;
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
    if (membership) {
        return { quiz, role: membership.role };
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
