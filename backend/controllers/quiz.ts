import { FindOptions, NonNullFindOptions } from "sequelize/types";
import ErrorStatus from "../helpers/error";
import { Quiz, Question } from "../models";
import { OptionAttributes } from "../models/question";

// Create quiz
export const createQuiz = async (userId: number) => {
    return await Quiz.create({
        userId,
    });
};

// Get all quiz
export const getAllQuiz = async (userId: number) => {
    const quiz = await Quiz.findAll({
        where: { userId },
        include: ["questions"],
    });
    return quiz;
};

// Get quiz
export const getQuiz = async (userId: number, quizId: number) => {
    return await getQuizCreator(userId, quizId, { include: ["questions"] });
};

// Check quiz and check permissions
export const getQuizCreator = async (
    userId: number,
    quizId: number,
    options?: FindOptions
) => {
    const quiz = await Quiz.findByPk(quizId, options);
    if (!quiz) {
        const err = new ErrorStatus("Quiz not found", 404);
        throw err;
    }
    if (quiz.userId != userId) {
        const err = new ErrorStatus("Permission denied", 403);
        throw err;
    }
    return quiz;
};

// Update quiz attributes
export const updateQuiz = async (quiz: Quiz, info: any) => {
    // Make updates
    if (info.title) {
        quiz.title = info.title;
        quiz.description = info.description;
    }
    return await quiz.save();
};

// Delete quiz
export const deleteQuiz = async (quizId: number) => {
    // Now destroy the quiz
    return await Quiz.destroy({ where: { id: quizId } });
};

// Parse question options
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

// Parses question info
interface QuestionInfo {
    text?: string;
    type: string;
    timeLimit?: number;
    tf?: boolean;
    options?: OptionAttributes[];
}
const checkQuestionInfo = (info: any): QuestionInfo => {
    const values: QuestionInfo = {
        type: info.type,
        text: info.text,
        timeLimit: Number(info.timeLimit) >= 5 ? Number(info.timeLimit) : null,
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

// Add question
export const addQuestion = async (quizId: number, info: any) => {
    const question = await Question.create({
        ...checkQuestionInfo(info),
        quizId,
    });
    return question;
};

// Update question
export const updateQuestion = async (
    quizId: number,
    questionId: number,
    info: any
) => {
    // Check input
    const questionInfo = checkQuestionInfo(info);

    // Update and return
    const updated = await Question.update(
        { ...questionInfo, quizId },
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

// Delete question
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
