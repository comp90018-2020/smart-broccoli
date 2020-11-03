import { FindOptions } from "sequelize";
import ErrorStatus from "../helpers/error";
import { Op } from "sequelize";
import sequelize, {
    Quiz,
    Question,
    UserGroup,
    User,
    Session,
    Group,
    Picture,
} from "../models";
import { processQuestions } from "./question";
import { deletePicture, insertPicture } from "./picture";
import { assertGroupOwnership } from "./group";
import { sessionTokenDecrypt } from "./session";
import { exception } from "console";

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
    const quiz = await Quiz.findByPk(
        quizId,
        options
            ? {
                  ...options,
                  attributes: options.attributes
                      ? [
                            ...(options.attributes as string[]),
                            "groupId",
                            "active",
                        ]
                      : options.attributes,
              }
            : undefined
    );
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

    // Not active?
    if (!quiz.active) {
        throw new ErrorStatus("Quiz is not active", 403);
    }

    // Find user's quiz sessions
    // This query is not ideal
    const sessions = await Session.findAll({
        where: { quizId, state: { [Op.not]: "lost" } },
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
    if (info.active !== undefined && quiz.type !== "live") {
        quiz.active = info.active;
    }
    if (info.timeLimit) {
        quiz.timeLimit = info.timeLimit;
    }
    if (info.description !== undefined) {
        quiz.description = info.description;
    }

    return await sequelize.transaction(async (transaction) => {
        await quiz.save({ transaction: transaction });

        // Save questions
        const quizJSON: any = {
            ...quiz.toJSON(),
            questions: (
                await processQuestions(transaction, quiz.id, [], info.questions)
            ).map((q) => q.toJSON()),
        };
        return quizJSON;
    });
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
        if (info.type === "self paced") {
            // Changes to self-paced quiz
            quiz.active = info.active;
        } else if (info.type === undefined && quiz.type === "self paced") {
            // Changes to self-paced quiz
            quiz.active = info.active;
        } else if (quiz.type !== "live" && info.type === "live") {
            // Change to live quiz
            quiz.active = false;
        }
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
    if (info.description !== undefined) {
        quiz.description = info.description;
    }

    return await sequelize.transaction(async (transaction) => {
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
        return quizJSON;
    });
};

/**
 * Get all quiz that user has access to.
 * @param User
 */
export const getAllQuiz = async (
    userId: number,
    opts: { role?: string } = {}
) => {
    // Unset if all
    if (opts.role === "all") {
        opts.role = undefined;
    }

    // Get quizzes of user's groups
    const groups = await Group.findAll({
        include: [
            {
                // @ts-ignore
                model: User,
                where: { id: userId },
                through: {
                    where: opts.role ? { role: opts.role } : undefined,
                    attributes: ["role"],
                },
                attributes: ["id"],
                required: true,
            },
            {
                // @ts-ignore
                model: Quiz,
                required: false,
                include: [
                    {
                        // @ts-ignore
                        model: Session,
                        required: false,
                        where: { state: { [Op.not]: "lost" } },
                        include: [
                            {
                                // @ts-ignore
                                model: User,
                                required: false,
                                attributes: ["id"],
                                where: { id: userId },
                                through: { attributes: ["state"] },
                            },
                        ],
                    },
                ],
            },
        ],
    });

    return groups
        .map((group) => {
            const role = group.Users[0].UserGroup.role;

            return group.Quizzes.filter((quiz) => {
                // Members are allowed to see active quizzes only
                if (role === "member") {
                    return quiz.active;
                }
                // For owners
                return true;
            }).map((quiz) => {
                return {
                    ...quiz.toJSON(),
                    role,
                    // Whether user has completed quiz
                    complete:
                        quiz.Sessions.find(
                            (session) =>
                                session.Users.length > 0 &&
                                session.Users[0].SessionParticipant.state ===
                                    "complete"
                        ) != null,
                    // Filter to sessions that user is member of
                    // and those waiting for more members
                    Sessions: quiz.Sessions.filter(
                        (session) =>
                            session.state === "waiting" ||
                            session.Users.length > 0
                    ).map((session) => {
                        // @ts-ignore
                        const sessionJSON: any = session.toJSON();
                        delete sessionJSON["Users"];
                        return sessionJSON;
                    }),
                };
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
                as: "questions",
            },
            {
                // @ts-ignore
                model: Session,
                required: false,
                where: { state: { [Op.not]: "lost" } },
                include: [
                    {
                        // @ts-ignore
                        model: User,
                        required: false,
                        attributes: ["id"],
                        where: { id: userId },
                        through: { attributes: ["state"] },
                    },
                ],
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
                // Number of correct answers
                numCorrect: question.numCorrect,
                // Possibly null for truefalse
                options: question.options
                    ? question.options.map((opt) => {
                          return {
                              ...opt,
                              correct: null,
                          };
                      })
                    : null,
            };
        });
    } else {
        // Haven't started quiz, no access to questions
        questions = null;
    }

    return {
        ...quiz.toJSON(),
        role,
        // Whether user has completed quiz
        complete:
            quiz.Sessions.find(
                (session) =>
                    session.Users.length > 0 &&
                    session.Users[0].SessionParticipant.state === "complete"
            ) != null,
        // Filter to sessions that user is member of
        // and those waiting for more members
        Sessions: quiz.Sessions.filter(
            (session) => session.state === "waiting" || session.Users.length > 0
        ).map((session) => {
            // @ts-ignore
            const sessionJSON: any = session.toJSON();
            delete sessionJSON["Users"];
            return sessionJSON;
        }),
        questions,
    };
};

/**
 * Delete quiz.
 * @param quizId
 */
export const deleteQuiz = async (userId: number, quizId: number) => {
    const { quiz, role } = await getQuizAndRole(userId, quizId, {
        attributes: ["id"],
    });
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
    const { quiz, role } = await getQuizAndRole(userId, quizId, {
        attributes: ["id", "pictureId"],
    });
    if (role !== "owner") {
        throw new ErrorStatus("Cannot update picture", 403);
    }

    return await sequelize.transaction(async (transaction) => {
        // Delete old picture
        if (quiz.pictureId) {
            await deletePicture(quiz.pictureId, transaction);
        }

        // Insert new picture
        const picture = await insertPicture(transaction, file);

        // Set picture
        quiz.pictureId = picture.id;
        await quiz.save({ transaction });
        return quiz;
    });
};

/**
 * Get quiz picture.
 * @param quiz Quiz object
 */
export const getQuizPicture = async (
    userId: number,
    token: string,
    quizId: number
) => {
    // Check session token
    const decryptedToken = await sessionTokenDecrypt(token);
    if (decryptedToken) {
        // Bad token
        if (decryptedToken.quizId !== quizId)
            throw new ErrorStatus("Session token mismatch", 403);

        // Get picture
        const quiz = await Quiz.findByPk(quizId, {
            attributes: ["pictureId"],
            include: [
                {
                    // @ts-ignore
                    model: Picture,
                    attributes: ["id", "destination"],
                },
            ],
        });
        return quiz.Picture;
    }

    // Ensure that user can access quiz
    const { quiz } = await getQuizAndRole(userId, quizId, {
        attributes: ["pictureId"],
        include: [
            {
                // @ts-ignore
                model: Picture,
                attributes: ["id", "destination"],
            },
        ],
    });
    return quiz.Picture;
};

/**
 * Delete quiz picture.
 * @param userId
 * @param quizId
 */
export const deleteQuizPicture = async (userId: number, quizId: number) => {
    // Ensure that user is owner
    const { quiz, role } = await getQuizAndRole(userId, quizId, {
        attributes: ["pictureId"],
    });
    if (role !== "owner") {
        throw new ErrorStatus("Cannot delete picture", 403);
    }
    return await deletePicture(quiz.pictureId);
};
