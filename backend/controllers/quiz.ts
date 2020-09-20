import ErrorStatus from "../helpers/error";
import { Quiz, Question } from "../models";
import { OptionAttributes } from "../models/question";

// Create quiz
export const createQuiz = async (userId: number) => {
    return await Quiz.create({
        userId,
    });
};

// Get quiz
export const getQuiz = async (quizId: number) => {
    const quiz = await Quiz.findByPk(quizId, {
        include: ["Quiz", "QuizOption"],
    });
    if (!quiz) {
        const err = new ErrorStatus("Quiz not found", 404);
        throw err;
    }
    return quiz;
};

// Check quiz and check permissions
const getAndCheckPermissions = async (userId: number, quizId: number) => {
    const quiz = await Quiz.findByPk(quizId);
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
export const updateQuiz = async (userId: number, quizId: number, info: any) => {
    const quiz = await getAndCheckPermissions(userId, quizId);

    // Make updates
    if (info.title) {
        quiz.title = info.title;
        quiz.description = info.description;
    }
    return await quiz.save();
};

// Delete quiz
export const deleteQuiz = async (userId: number, quizId: number) => {
    // Check user permissions
    await getAndCheckPermissions(userId, quizId);
    // Now destroy the quiz
    return await Quiz.destroy({ where: { id: quizId } });
};

// Parse question options
const parseOptions = (options: any): OptionAttributes[] => {
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
    text: string;
    type: string;
    timeLimit?: number;
    tf?: boolean;
    options?: OptionAttributes[];
}
const parseQuestionInfo = (info: any): QuestionInfo => {
    const { text, type, options, tf, timeLimit } = info;
    const values: QuestionInfo = {
        text,
        type,
    };
    // Time limit
    if (timeLimit && timeLimit > 0) {
        values.timeLimit = timeLimit;
    } else {
        values.timeLimit = null;
    }
    // True/false questions
    if (type === "truefalse") {
        if (!values.tf) {
            const err = new ErrorStatus("tf not specified", 400);
            throw err;
        }
        values.tf = tf;
    }
    // Multiple choice
    if (type === "choice") {
        values.options = parseOptions(options);
    }
    return values;
};

// Add question
export const addQuestion = async (
    userId: number,
    quizId: number,
    info: any
) => {
    await getAndCheckPermissions(userId, quizId);
    const question = await Question.create({
        ...parseQuestionInfo(info),
        quizId,
    });
    return question;
};

// Update question
export const updateQuestion = async (
    userId: number,
    quizId: number,
    questionId: number,
    info: any
) => {
    // Check input
    await getAndCheckPermissions(userId, quizId);
    const questionInfo = parseQuestionInfo(info);

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
