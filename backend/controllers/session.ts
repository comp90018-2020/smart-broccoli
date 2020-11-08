import { Op } from "sequelize";
import sequelize, {
    Quiz,
    Session,
    SessionParticipant,
    User,
    Group,
    UserGroup,
    Question,
} from "../models";
import ErrorStatus from "../helpers/error";
import { jwtSign, jwtVerify } from "../helpers/jwt";
import { handler } from "../game/index";
import {
    sendSessionActivateNotification,
    sendSessionCreationNotification,
} from "./notification_session";

// Represents a session token
export interface TokenInfo {
    scope: string;
    userId: number;
    role: string;
    sessionId: number;
    quizId: number;
}

/**
 * Sign game token.
 * @param sessionId
 * @param quizId
 * @param userId
 * @param role
 */
const signSessionToken = async (info: {
    sessionId: number;
    role: string;
    userId: number;
    quizId: number;
}) => {
    return await jwtSign(
        {
            scope: "game",
            userId: info.userId,
            role: info.role,
            sessionId: info.sessionId,
            quizId: info.quizId,
        },
        process.env.TOKEN_SECRET,
        { expiresIn: "1h" }
    );
};

/**
 * Determines whether user is in session by token.
 * @param token
 */
export const sessionTokenDecrypt = async (token: string) => {
    if (!token) {
        return null;
    }

    // Decrypt the session token
    try {
        const sessionToken: TokenInfo = await jwtVerify(
            token,
            process.env.TOKEN_SECRET
        );
        return sessionToken.scope === "game" ? sessionToken : null;
    } catch (err) {
        return null;
    }
};

/**
 * Determine whether session has user.
 * @param sessionId
 * @param userId
 */
export const sessionHasUser = async (sessionId: number, userId: number) => {
    return await SessionParticipant.count({
        where: { sessionId, userId },
    });
};

/**
 * Get partial user session information.
 * @param userId
 */
const isInSession = async (userId: number) => {
    // Find active/waiting sessions which user has not left
    // @ts-ignore
    const count: number = await Session.count({
        where: {
            state: {
                [Op.or]: ["active", "waiting"],
            },
        },
        include: [
            {
                // @ts-ignore
                model: User,
                through: { where: { state: { [Op.not]: "left" } } },
                where: {
                    id: userId,
                },
            },
        ],
    });
    return count === 1;
};

/**
 * Get session that user is in.
 * @param userId
 */
export const getUserSession = async (userId: number) => {
    // Get session of quiz
    // @ts-ignore
    const session = await Session.findOne({
        where: {
            state: {
                [Op.or]: ["active", "waiting"],
            },
        },
        include: [
            {
                // Find current user
                model: User,
                attributes: ["id"],
                through: {
                    where: { state: { [Op.not]: "left" } },
                    attributes: ["role"],
                },
                where: { id: userId },
                required: true,
            },
            {
                // Get group
                // @ts-ignore
                model: Group,
                attributes: ["id", "name", "defaultGroup", "code"],
                include: [
                    {
                        // Get owner name (for default groups)
                        model: User,
                        through: { where: { role: "owner" } },
                        attributes: ["name"],
                        required: true,
                    },
                ],
            },
        ],
    });

    // No session
    if (!session) {
        return null;
    }

    // Remove Users from session
    const sessionJSON: any = session.toJSON();
    delete sessionJSON["Users"];
    // Remove Users from group
    const groupJSON: any = session.Group.toJSON();
    delete groupJSON["Users"];
    // Remove code from group
    if (!session.subscribeGroup) {
        delete groupJSON["code"];
    }

    // Sign the token and return
    const token = await signSessionToken({
        sessionId: session.id,
        role: session.Users[0].SessionParticipant.role,
        userId,
        quizId: session.quizId,
    });
    return {
        session: {
            ...sessionJSON,
            Group: {
                ...groupJSON,
                // Name for default group
                name: session.Group.defaultGroup
                    ? session.Group.Users[0].name
                    : session.Group.name,
            },
        },
        token,
    };
};

/**
 * Generates codes to specified length.
 * @param length
 */
const CHARSET = "0123456789";
const generateCode = (length: number) => {
    return [...Array(length)]
        .map(
            () =>
                CHARSET[Math.floor(Math.random() * Math.floor(CHARSET.length))]
        )
        .join("");
};

/**
 * Create quiz session.
 * @param userId
 * @param opts
 */
export const createSession = async (userId: number, opts: any) => {
    const { quizId, isGroup, subscribeGroup } = opts;

    // Check session
    const existingSession = await isInSession(userId);
    if (existingSession) {
        throw new ErrorStatus(
            "User is already participant of ongoing quiz session",
            400
        );
    }

    // Get quiz
    const quiz = await Quiz.findByPk(quizId, {
        include: [
            {
                // @ts-ignore
                model: Question,
                as: "questions",
            },
        ],
        order: [["questions", "index", "ASC"]],
    });
    if (!quiz) {
        throw new ErrorStatus("Quiz not found", 404);
    }
    if (quiz.questions.length === 0) {
        throw new ErrorStatus("Quiz has zero questions", 400);
    }

    // Find group/role
    const groupRole = await UserGroup.findOne({
        where: { groupId: quiz.groupId, userId },
        attributes: ["role"],
    });
    if (!groupRole) {
        throw new ErrorStatus("Quiz cannot be accessed", 403);
    }
    const role = groupRole.role;

    // Get role
    // Check quiz type/initiator
    if (role === "owner" && quiz.type === "self paced") {
        throw new ErrorStatus("Owner cannot start self-paced quiz", 400);
    }
    if (role === "member" && quiz.type === "live") {
        throw new ErrorStatus("Users cannot start live quiz", 400);
    }
    if (role === "member" && quiz.type === "self paced" && !quiz.active) {
        throw new ErrorStatus(
            "Users cannot start inactive self-paced quiz",
            400
        );
    }

    // Initial state of quiz
    let state = "waiting";
    if (quiz.type === "self paced" && !isGroup) {
        // Alone quizzes
        state = "active";
    }

    // Create session
    const session = new Session({
        isGroup,
        type: quiz.type,
        state,
        quizId: quiz.id,
        groupId: quiz.groupId,
        subscribeGroup,
    });

    return await sequelize.transaction(async (transaction) => {
        // Change live quiz to active state
        if (quiz.type === "live") {
            quiz.active = true;
            await quiz.save({ transaction });
        }

        // Save session
        await session.save({ transaction });

        // Regenerate code
        let attempt = 0;
        while (true) {
            try {
                session.code = generateCode(6);
                await session.save({ transaction });
                break;
            } catch (err) {
                // Continue
                attempt += 1;
                if (attempt > 5) {
                    // Stop, something's going wrong
                    throw new ErrorStatus("Cannot generate code", 500);
                }
            }
        }

        // Create session participant
        const sessionParticipant = new SessionParticipant({
            sessionId: session.id,
            userId,
            role: role === "owner" ? "host" : "participant",
        });
        await sessionParticipant.save({ transaction });

        // Sign code
        const token = await signSessionToken({
            sessionId: session.id,
            userId,
            role: sessionParticipant.role,
            quizId: quiz.id,
        });

        // pass quiz and session to socket
        handler.addSession(quiz, session.id, session.type, session.isGroup);

        // push notifications
        if (process.env.NODE_ENV === "production") {
            sendSessionCreationNotification(userId, session, quiz);
        } else {
            await sendSessionCreationNotification(userId, session, quiz);
        }

        return { session, token };
    });
};

/**
 * Join session.
 * @param userId ID of user
 * @param code Game code
 */
export const joinSession = async (userId: number, code: string) => {
    // Check session
    const existingSession = await isInSession(userId);
    if (existingSession) {
        throw new ErrorStatus(
            "User is already participant of ongoing quiz session",
            400
        );
    }

    // Find session with code
    // @ts-ignore
    const session = await Session.findOne({
        where: { code, state: { [Op.not]: "ended" } },
        include: [
            // Get group
            {
                model: Group,
                attributes: ["id", "name", "defaultGroup", "code"],
                required: true,
                include: [
                    {
                        // Get owner name
                        model: User,
                        through: { where: { role: "owner" } },
                        attributes: ["name"],
                        required: true,
                    },
                ],
            },
            // Get quiz
            {
                model: Quiz,
                attributes: ["type"],
            },
            // Has user joined before?
            {
                model: User,
                attributes: ["id"],
                through: {
                    attributes: ["id", "state"],
                },
                where: { id: userId },
                required: false,
            },
        ],
    });
    if (!session) {
        throw new ErrorStatus("Cannot find session with code", 404);
    }

    // Update SessionParticipant
    if (session.Users.length > 0 && session.state != "complete") {
        // Let user rejoin (as they regret leaving...)
        await session.Users[0].SessionParticipant.update({
            state: "joined",
        });
    } else if (
        // In waiting state OR in active state and is live quiz
        session.Users.length === 0 &&
        (session.state === "waiting" ||
            (session.state === "active" && session.Quiz.type === "live"))
    ) {
        // Create association
        await SessionParticipant.create({
            sessionId: session.id,
            userId,
            role: "participant",
        });
    } else {
        throw new ErrorStatus("Session cannot be joined", 400, {
            state: session.state,
        });
    }

    // Remove Users from session
    const sessionJSON: any = session.toJSON();
    delete sessionJSON["Users"];
    // Remove Users from group
    const groupJSON: any = session.Group.toJSON();
    delete groupJSON["Users"];
    // Remove code from group
    if (!session.subscribeGroup) {
        delete groupJSON["code"];
    }

    // Sign code
    const token = await signSessionToken({
        sessionId: session.id,
        role: "participant",
        userId,
        quizId: session.quizId,
    });
    return {
        session: {
            ...sessionJSON,
            Group: {
                ...groupJSON,
                // Name for default group
                name: session.Group.defaultGroup
                    ? session.Group.Users[0].name
                    : session.Group.name,
            },
        },
        token,
    };
};

/**
 * Moves a session to activated state
 * @param sessionId
 */
export const activateSession = async (sessionId: number) => {
    try {
        const res = await Session.update(
            { state: "active" },
            { where: { id: sessionId }, returning: true }
        );
        const session = res[1][0];

        // push notifications
        if (process.env.NODE_ENV === "production") {
            sendSessionActivateNotification(
                sessionId,
                session.groupId,
                session.quizId
            );
        } else {
            await sendSessionActivateNotification(
                sessionId,
                session.groupId,
                session.quizId
            );
        }

        return res[0] === 1;
    } catch (err) {
        // Game server calls function, game server should not be responsible
        // for handling errors
    }
};

/**
 * Handle cases where users leave session.
 * @param sessionId
 * @param userId
 */
export const leaveSession = async (sessionId: number, userId: number) => {
    const sessionParticipant = await SessionParticipant.update(
        {
            state: "left",
        },
        {
            where: { userId, sessionId },
        }
    );
    return sessionParticipant[0] === 1;
};

/**
 * End session and save progress.
 * @param sessionId
 * @param complete Successful completion?
 * @param progress
 */
export const endSession = async (
    sessionId: number,
    complete: boolean,
    progress: { userId: number; data: any; state?: string }[]
) => {
    try {
        const session = await Session.findByPk(sessionId, {
            // @ts-ignore
            include: { model: Quiz, attributes: ["id", "type"] },
            attributes: ["id"],
        });

        await sequelize.transaction(async (transaction) => {
            // If live quiz, deactivate
            if (session.Quiz.type === "live") {
                await session.Quiz.update({ active: false }, { transaction });
            }

            // Session has ended
            await session.update(
                {
                    state: "ended",
                    code: null,
                },
                {
                    transaction,
                }
            );

            // Update user entries according to progress held by game
            for (const entry of progress) {
                await SessionParticipant.update(
                    {
                        progress: entry.data,
                        state: entry.state || complete ? "complete" : "left",
                    },
                    {
                        where: { userId: entry.userId, sessionId },
                        transaction,
                    }
                );
            }

            // Those who are still in the joined state should be removed
            // Or they will be in limbo
            await SessionParticipant.update(
                { state: "lost" },
                { where: { state: "joined" }, transaction }
            );
        });
    } catch (err) {
        throw err;
    }
};

/**
 * Clear sessions in database
 * make active or waiting sessions' state lost
 * also make joined participants' state lost
 */
export const clearSessions = async () => {
    // Update sessions to lost
    await Session.update(
        { code: null, state: "lost" },
        {
            where: {
                state: {
                    [Op.or]: ["active", "waiting"],
                },
            },
        }
    );

    // Update session participants to lost
    await SessionParticipant.update(
        { state: "lost" },
        {
            where: {
                state: "joined",
            },
        }
    );

    // Deactivate live sessions
    await Quiz.update({ active: false }, { where: { type: "live" } });
};
