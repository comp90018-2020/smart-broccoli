import { Transaction } from "sequelize";
import ErrorStatus from "../helpers/error";
import sequelize, { Quiz } from "../models";
import Question, { OptionAttributes } from "../models/question";
import { deletePicture, getPictureById, insertPicture } from "./picture";

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
 * Parse options array of question.
 * @param options Options array
 */
const checkOptions = (options: any): OptionAttributes[] => {
    if (!Array.isArray(options)) {
        const err = new ErrorStatus("Options is not array", 400);
        throw err;
    }
    return options.map((option) => {
        return {
            correct: option.correct ? true : false,
            text: option.text ? option.text : "",
        };
    });
};

/**
 * Parses question info.
 * @param info Represents a question
 */
export const checkQuestionInfo = (info: any): QuestionInfo => {
    const values: QuestionInfo = {
        id: info.id,
        type: info.type,
        text: info.text,
        options: info.options
    };

    const { type, options, tf } = info;
    if (type === "truefalse") {
        // True/false questions
        if (typeof tf != "boolean") {
            const err = new ErrorStatus("tf not specified", 400);
            throw err;
        }
        values.tf = tf;
    } else if (type === "choice") {
        // Multiple choice
        values.options = checkOptions(options);
        if (values.options.length <= 1 || values.options.length > 4) {
            const err = new ErrorStatus(
                "Question should have between 2 and 4 options",
                400
            );
            throw err;
        }
    } else {
        const err = new ErrorStatus("Unknown type", 400);
        throw err;
    }
    return values;
};

/**
 * Add question to quiz.
 * @param quizId
 * @param info Question info
 */
export const addQuestion = async (
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
export const updateQuestion = async (
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
        const err = new ErrorStatus("Question not found", 404);
        throw err;
    }
    // Should not update more than 1 row
    if (updated[0] > 1) {
        const err = new ErrorStatus("Internal Server Error", 500);
        throw err;
    }
    return updated[1][0];
};

/**
 * Delete question.
 * @param quizId
 * @param questionId
 */
export const deleteQuestion = async (
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
        const err = new ErrorStatus("Bad Request", 400);
        throw err;
    }
};

/**
 * Update question picture.
 * @param quizId
 * @param questionId
 * @param file Metadata about file
 */
export const updateQuestionPicture = async (
    quizId: number,
    questionId: number,
    file: any
) => {
    const question = await Question.findOne({
        where: {
            quizId,
            id: questionId,
        },
    });
    if (!question) {
        const err = new ErrorStatus("Cannot find question", 404);
        throw err;
    }

    const transaction = await sequelize.transaction();
    try {
        // Delete the old picture
        if (question.pictureId) {
            await deletePicture(transaction, question.pictureId);
        }
        // Insert the new picture
        const picture = await insertPicture(transaction, file);
        // Set user picture
        question.pictureId = picture.id;
        await question.save({ transaction });
        await transaction.commit();
        return question;
    } catch (err) {
        await transaction.rollback();
        throw err;
    }
};

/**
 * Get question picture.
 * @param quizId
 * @param questionId
 */
export const getQuestionPicture = async (
    quizId: number,
    questionId: number
) => {
    const question = await Question.findOne({
        where: {
            quizId,
            id: questionId,
        },
    });
    if (!question) {
        const err = new ErrorStatus("Cannot find question", 404);
        throw err;
    }
    return await getPictureById(question.pictureId);
};
