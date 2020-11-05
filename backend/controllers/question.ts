import { Transaction } from "sequelize";
import ErrorStatus from "../helpers/error";
import sequelize, { Picture } from "../models";
import Question, { OptionAttributes } from "../models/question";
import { deletePicture, insertPicture } from "./picture";
import { getQuizAndRole } from "./quiz";
import { sessionTokenDecrypt } from "./session";

// Parses question info
interface QuestionInfo {
    id?: number;
    picture?: number;
    text?: string;
    type: string;
    tf?: boolean;
    options?: OptionAttributes[];
}

/**
 * Processes questions of a quiz (since we don't operate on questions directly).
 * @param quizId
 * @param original Original quiz questions
 * @param updated Updated quiz questions
 */
export const processQuestions = async (
    transaction: Transaction,
    quizId: number,
    original: Question[],
    updated: any[]
) => {
    // Quiz with no questions
    if (!updated) {
        updated = [];
    }

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

    const questions: Question[] = [];
    for (const question of updatedQuestions) {
        if (!question.id) {
            // Insert new questions (no id)
            questions.push(await addQuestion(transaction, quizId, question));
        } else if (originalIds.includes(question.id)) {
            // If updated
            questions.push(
                await updateQuestion(transaction, quizId, question.id, question)
            );
        }
    }
    return questions;
};

/**
 * Parse options array of question.
 * @param options Options array
 */
const checkOptions = (options: any): OptionAttributes[] => {
    if (!Array.isArray(options)) {
        throw new ErrorStatus("Options is not array", 400);
    }
    return options.map((option) => {
        return {
            correct: option.correct,
            text: option.text ? option.text : "",
        };
    });
};

/**
 * Parses question info.
 * @param info Represents a question
 */
const checkQuestionInfo = (info: any): QuestionInfo => {
    const values: QuestionInfo = {
        id: info.id,
        type: info.type,
        text: info.text,
    };

    const { type, options, tf } = info;
    if (type === "truefalse") {
        // True/false questions
        if (typeof tf != "boolean") {
            throw new ErrorStatus("tf not specified", 400);
        }
        values.tf = tf;
        values.options = null;
    } else if (type === "choice") {
        // Multiple choice
        values.options = checkOptions(options);
        values.tf = null;
        if (values.options.length <= 1 || values.options.length > 4) {
            throw new ErrorStatus(
                "Question should have between 2 and 4 options",
                400
            );
        }
    } else {
        throw new ErrorStatus("Unknown type", 400);
    }
    return values;
};

/**
 * Add question to quiz.
 * @param quizId
 * @param info Question info
 */
const addQuestion = async (
    transaction: Transaction,
    quizId: number,
    info: QuestionInfo
) => {
    const question = await Question.create(
        {
            ...info,
            quizId,
        },
        { transaction }
    );
    return question;
};

/**
 * Update existing question.
 * @param quizId
 * @param questionId
 * @param info Question info
 */
const updateQuestion = async (
    transaction: Transaction,
    quizId: number,
    questionId: number,
    info: QuestionInfo
) => {
    // Update and return
    const updated = await Question.update(
        { ...info },
        { where: { id: questionId, quizId }, returning: true, transaction }
    );
    if (updated[0] == 0) {
        throw new ErrorStatus("Question not found", 404);
    }
    // Should not update more than 1 row
    if (updated[0] > 1) {
        throw new ErrorStatus("Internal Server Error", 500);
    }
    return updated[1][0];
};

/**
 * Delete question.
 * @param quizId
 * @param questionId
 */
const deleteQuestion = async (
    transaction: Transaction,
    quizId: number,
    questionId: number
) => {
    const deleted = await Question.destroy({
        where: {
            id: questionId,
            quizId,
        },
        transaction,
    });
    if (deleted == 0) {
        throw new ErrorStatus("Cannot delete specified question", 400);
    }
};

/**
 * Update question picture.
 * @param quizId
 * @param questionId
 * @param file Metadata about file
 */
export const updateQuestionPicture = async (
    userId: number,
    quizId: number,
    questionId: number,
    file: any
) => {
    // Ensure that user is owner
    const { role } = await getQuizAndRole(userId, quizId, { attributes: [] });
    if (role !== "owner") {
        throw new ErrorStatus("Cannot update picture", 403);
    }

    const question = await Question.findOne({
        where: {
            quizId,
            id: questionId,
        },
        attributes: ["id", "pictureId"],
    });
    if (!question) {
        throw new ErrorStatus("Cannot find question", 404);
    }

    return await sequelize.transaction(async (transaction) => {
        // Delete the old picture
        if (question.pictureId) {
            await deletePicture(question.pictureId, transaction);
        }

        // Insert the new picture
        const picture = await insertPicture(transaction, file);

        // Set question picture
        question.pictureId = picture.id;
        return await question.save({ transaction });
    });
};

/**
 * Get question picture.
 * @param quizId
 * @param questionId
 */
export const getQuestionPicture = async (
    userId: number,
    token: string,
    quizId: number,
    questionId: number
) => {
    const decryptedToken = await sessionTokenDecrypt(token);
    if (decryptedToken) {
        // Check session token
        if (decryptedToken.quizId !== quizId)
            throw new ErrorStatus("Session token mismatch", 403);
        // Fall through when token is valid
    } else {
        // Check user permission
        const { role, state } = await getQuizAndRole(userId, quizId, {
            attributes: [],
        });
        if (
            (role === "member" || role === "participant") &&
            state === "inaccessible"
        ) {
            throw new ErrorStatus("Cannot access resource (yet)", 403);
        }
    }

    const question = await Question.findOne({
        attributes: ["id"],
        where: {
            quizId,
            id: questionId,
        },
        include: [
            {
                // @ts-ignore
                model: Picture,
                required: true,
                attributes: ["id", "destination"],
            },
        ],
    });
    if (!question) {
        throw new ErrorStatus("Cannot find question", 404);
    }
    return question.Picture;
};

/**
 * Delete question picture.
 * @param userId
 * @param quizId
 */
export const deleteQuestionPicture = async (
    userId: number,
    quizId: number,
    questionId: number
) => {
    // Ensure that user is owner
    const { role } = await getQuizAndRole(userId, quizId, { attributes: [] });
    if (role !== "owner") {
        throw new ErrorStatus("Cannot update picture", 403);
    }

    // Get question
    const question = await Question.findOne({
        where: {
            quizId,
            id: questionId,
        },
        attributes: ["pictureId"],
    });
    if (!question) {
        throw new ErrorStatus("Cannot find question", 404);
    }

    return await deletePicture(question.pictureId);
};
