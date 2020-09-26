import { FindOptions } from "sequelize/types";
import ErrorStatus from "../helpers/error";
import { Op } from "sequelize";
import { Quiz, Question, UserGroup, Group } from "../models";
import { OptionAttributes } from "../models/question";
import { deletePicture, getPictureById, insertPicture } from "./picture";

const processQuestions = async (original: Question[], updated: any) => {

};

/**
 * Create quiz.
 * @param userId ID of creator
 * @param info
 */
export const createQuiz = async (info: any) => {
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
    const quizJSON: any = quiz.toJSON();
    quizJSON.questions = await processQuestions([], info.questions);
    return quizJSON;
};

// Update quiz attributes
export const updateQuiz = async (quizId: number, info: any) => {
    // Get quiz
    const quiz = await Quiz.findByPk(quizId, {
        // @ts-ignore
        include: {
            model: Question,
            as: "questions",
        },
    });
    quiz.title = info.title;
    quiz.type = info.type;
    quiz.groupId = info.groupId;

    // Make updates
    if (info.timeLimit) {
        quiz.timeLimit = info.timeLimit;
    }
    if (info.description) {
        quiz.description = info.description;
    }
    await quiz.save();

    // Save questions
    const quizJSON: any = quiz.toJSON();
    quizJSON.questions = await processQuestions(quiz.questions, info.questions);
    return quizJSON;
};

/**
 * Get all quiz that user has access to.
 * @param userId
 */
export const getAllQuiz = async (userId: number) => {
    // All groups and associated quiz where user is member
    const userGroups = await UserGroup.findAll({
        where: {
            userId,
        },
    });

    // Find all quizzes and return whether user is participant or owner
    // TODO: live quiz
    const quizzes = await Quiz.findAll({
        where: { groupId: { [Op.or]: userGroups.map((g) => g.groupId) } },
    });
    return quizzes.map((quiz) => {
        return {
            ...quiz,
            role: userGroups.find((g) => g.id === quiz.groupId).role,
        };
    });
};

// Get quiz
export const getQuiz = async (userId: number, quizId: number) => {
    const { quiz, role } = await getQuizAndRole(userId, quizId, {
        include: ["questions"],
    });
    const quizJSON = {
        ...quiz.toJSON(),
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

// Check quiz and check permissions
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
    id?: number;
    picture?: number;
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
const addQuestion = async (quizId: number, info: any) => {
    const question = await Question.create({
        ...checkQuestionInfo(info),
        quizId,
    });
    return question;
};

// Update question
const updateQuestion = async (
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
const deleteQuestion = async (quizId: number, questionId: number) => {
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

// Update question picture
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

// Get question picture
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
