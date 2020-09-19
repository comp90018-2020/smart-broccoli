import ErrorStatus from "../helpers/error";
import { User, Quiz, Question } from "../models";

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

// Update quiz attributes
export const updateQuiz = async (quizId: number, info: any) => {
    const quiz = await Quiz.findByPk(quizId);
    if (!quiz) {
        const err = new ErrorStatus("Quiz not found", 404);
        throw err;
    }

    if (info.title) {
        quiz.title = info.title;
        quiz.description = info.description;
    }

    return await quiz.save();
};

// Delete quiz
export const deleteQuiz = async (quizId: number) => {
    const quiz = await Quiz.findByPk(quizId);
    if (!quiz) {
        const err = new ErrorStatus("Quiz not found", 404);
        throw err;
    }

    return await Quiz.destroy({ where: { id: quizId } });
};

// Add question
export const addQuestion = async (quizId: number, info: any) => {
    const { text } = info;
    return await Question.create({ text, quizId });
};
