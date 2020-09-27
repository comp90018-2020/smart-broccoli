import ErrorStatus from "../helpers/error";
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
export const addQuestion = async (quizId: number, info: QuestionInfo) => {
    const question = await Question.create({
        ...info,
        quizId,
    });
    return question;
};

/**
 * Update existing question.
 * @param quizId
 * @param questionId
 * @param info Question info
 */
export const updateQuestion = async (
    quizId: number,
    questionId: number,
    info: QuestionInfo
) => {
    // Update and return
    const updated = await Question.update(
        { ...info, quizId },
        { where: { id: questionId, quizId }, returning: true }
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
export const deleteQuestion = async (quizId: number, questionId: number) => {
    const deleted = await Question.destroy({
        where: {
            id: questionId,
            quizId,
        },
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
        const err = new ErrorStatus("Cannot found question", 404);
        throw err;
    }

    // Delete the old picture
    if (question.pictureId) {
        await deletePicture(question.pictureId);
    }
    // Insert the new picture
    const picture = await insertPicture(file);
    // Set user picture
    question.pictureId = picture.id;
    return await question.save();
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
        const err = new ErrorStatus("Cannot found question", 404);
        throw err;
    }
    return await getPictureById(question.pictureId);
};
