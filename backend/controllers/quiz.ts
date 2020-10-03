import { FindOptions } from "sequelize";
import ErrorStatus from "../helpers/error";
import sequelize, { Quiz, Question, UserGroup, User, Session } from "../models";
import { processQuestions } from "./question";
import { deletePicture, getPictureById, insertPicture } from "./picture";
import { assertGroupOwnership } from "./group";

/**
 * Create quiz.
 * @param userId ID of creator
 * @param info
 */
export const createQuiz = async (userId: number, info: any) => {
    // Ensure that creator is owner
    await assertGroupOwnership(userId, info.groupId);

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
    if (!quiz) {
        throw new ErrorStatus("Quiz not found", 404);
    }

    // Ensure that creator is owner of group
    await assertGroupOwnership(userId, quiz.groupId);

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
export const getAllQuiz = async (user: User, opts: { role?: string } = {}) => {
    // Unset if all
    if (opts.role === "all") {
        opts.role = undefined;
    }

    // Get quizzes of user's groups
    const groups = await user.getGroups({
        where: opts.role ? { "$UserGroup.role$": opts.role } : undefined,
        include: [
            {
                // @ts-ignore
                model: Quiz,
                required: false,
                include: [
                    {
                        // @ts-ignore
                        model: Session,
                        required: false,
                        where: { state: "waiting" },
                    },
                ],
            },
        ],
    });

    return groups
        .map((group) => {
            return group.Quizzes.filter((quiz) => {
                // Members are not allowed to get non active quizzes
                return !(!quiz.active && group.UserGroup.role === "member");
            }).map((quiz) => {
                return { ...quiz.toJSON(), role: group.UserGroup.role };
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
        include: [
            {
                // @ts-ignore
                model: Question,
                as: 'questions'
            },
            {
                // @ts-ignore
                model: Session,
                required: false,
                where: { state: "waiting" },
            },
        ],
    });

    // Questions
    let questions: any = {};

    if (role === "owner" || state === "complete") {
        // Owners, members who completed quiz
        questions = quiz.questions.map((q) => q.toJSON());
    } else if (state === "accessible") {
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
        throw new ErrorStatus("Quiz not found", 404);
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

    // Find user's quiz sessions
    // This query is not ideal
    const sessions = await Session.findAll({
        where: { quizId },
        attributes: ["id", "state"],
        include: [
            {
                // @ts-ignore
                model: User,
                where: { id: userId },
                attributes: ["id"],
                required: true,
            },
        ],
    });

    // No sessions, not member
    if (sessions.length === 0 && !membership) {
        throw new ErrorStatus("Quiz cannot be accessed", 403);
    }

    // Determine role
    const role = membership ? membership.role : "participant";
    const states = sessions.map((session) => session.state);

    // Least progress should be chosen
    let state = "";
    if (sessions.length === 0) {
        // No session, so inaccessible
        state = "inaccessible";
    } else if (states.includes("waiting") || states.includes("active")) {
        state = "accessible";
    } else if (states.includes("complete")) {
        state = "complete";
    }

    return { quiz, role, state };
};

/**
 * Delete quiz.
 * @param quizId
 */
export const deleteQuiz = async (userId: number, quizId: number) => {
    const { quiz, role } = await getQuizAndRole(userId, quizId);
    if (role !== "owner") {
        throw new ErrorStatus("Cannot delete quiz", 403);
    }

    // Now destroy the quiz
    await quiz.destroy();
};

/**
 * Update quiz picture.
 * @param quiz Quiz object
 * @param file Metadata about uploaded file
 */
export const updateQuizPicture = async (
    userId: number,
    quizId: number,
    file: any
) => {
    // Ensure that user is owner
    const { quiz, role } = await getQuizAndRole(userId, quizId);
    if (role !== "owner") {
        throw new ErrorStatus("Cannot update picture", 403);
    }

    const transaction = await sequelize.transaction();
    try {
        // Delete old picture
        if (quiz.pictureId) {
            await deletePicture(quiz.pictureId, transaction);
        }
        // Insert new picture
        const picture = await insertPicture(transaction, file);
        // Set picture
        quiz.pictureId = picture.id;
        await quiz.save({ transaction });

        await transaction.commit();
        return quiz;
    } catch (err) {
        await transaction.rollback();
    }
};

/**
 * Get quiz picture.
 * @param quiz Quiz object
 */
export const getQuizPicture = async (userId: number, quizId: number) => {
    // Ensure that user can access quiz
    const { quiz } = await getQuizAndRole(userId, quizId);
    return await getPictureById(quiz.pictureId);
};

/**
 * Delete quiz picture.
 * @param userId
 * @param quizId
 */
export const deleteQuizPicture = async (userId: number, quizId: number) => {
    // Ensure that user is owner
    const { quiz, role } = await getQuizAndRole(userId, quizId);
    if (role !== "owner") {
        throw new ErrorStatus("Cannot delete picture", 403);
    }
    return await deletePicture(quiz.pictureId);
};
