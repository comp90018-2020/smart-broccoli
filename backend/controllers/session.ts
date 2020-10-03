import { Op } from "sequelize";
import sequelize, {
    Quiz,
    Session,
    SessionParticipant,
    User,
    Group,
    UserGroup,
} from "../models";
import ErrorStatus from "../helpers/error";
import { jwtSign } from "../helpers/jwt";

/**
 * Sign game token.
 * @param sessionId
 * @param quizId
 * @param userId
 * @param role
 */
const signSessionToken = async (
    sessionId: number,
    userId: number,
    role: string
) => {
    return await jwtSign(
        {
            scope: "game",
            userId,
            role,
            sessionId,
        },
        process.env.TOKEN_SECRET
    );
};

/**
 * Get partial user session information.
 * @param userId
 */
const getUserSessionPartial = async (userId: number) => {
    return await Session.findOne({
        where: {
            state: { [Op.or]: ["active", "waiting"] },
        },
        include: [
            {
                // Find current user
                // @ts-ignore
                model: User,
                attributes: ["id"],
                where: { id: userId },
                required: true,
            },
        ],
    });
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
            state: { [Op.or]: ["active", "waiting"] },
        },
        include: [
            {
                // Find current user
                model: User,
                attributes: ["id"],
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
                        // Get user
                        model: User,
                        where: { "$Group.Users.UserGroup.role$": "owner" },
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
    const token = await signSessionToken(
        session.id,
        userId,
        session.Users[0].SessionParticipant.role
    );
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
    const existingSession = await getUserSessionPartial(userId);
    if (existingSession) {
        throw new ErrorStatus(
            "User is already participant of ongoing quiz session",
            400
        );
    }

    // Get quiz
    const quiz = await Quiz.findByPk(quizId, { include: ["questions"] });

    // Check group
    const userGroup = await UserGroup.findOne({
        where: { userId, groupId: quiz.groupId },
    });
    if (!userGroup) {
        throw new ErrorStatus("User cannot access quiz", 403);
    }

    // Check quiz type/initiator
    if (userGroup.role === "owner" && quiz.type === "self paced") {
        throw new ErrorStatus("Owner cannot start self-paced quiz", 400);
    }
    if (userGroup.role === "member" && quiz.type === "live") {
        throw new ErrorStatus("Users cannot start live quiz", 400);
    }

    const transaction = await sequelize.transaction();

    // Create session
    const session = new Session({
        isGroup,
        type: quiz.type,
        state: "waiting",
        quizId: quiz.id,
        groupId: quiz.groupId,
        subscribeGroup,
    });

    try {
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
            role: userGroup.role === "owner" ? "host" : "participant",
        });
        await sessionParticipant.save({ transaction });

        // Commit
        await transaction.commit();

        // Sign code
        const token = await signSessionToken(
            session.id,
            userId,
            sessionParticipant.role
        );
        return { session, token };
    } catch (err) {
        await transaction.rollback();
        throw err;
    }
};

/**
 * Join session.
 * @param userId ID of user
 * @param code Game code
 */
export const joinSession = async (userId: number, code: string) => {
    // Check session
    const existingSession = await getUserSessionPartial(userId);
    if (existingSession) {
        throw new ErrorStatus(
            "User is already participant of ongoing quiz session",
            400
        );
    }

    // Find session with code
    // @ts-ignore
    const session = await Session.findOne({
        where: { code },
        include: [
            {
                // Get group
                model: Group,
                attributes: ["id", "name", "defaultGroup", "code"],
                include: [
                    {
                        // Get user
                        model: User,
                        where: { "$Group.Users.UserGroup.role$": "owner" },
                        attributes: ["name"],
                        required: true,
                    },
                ],
            },
        ],
    });
    if (!session) {
        throw new ErrorStatus("Cannot found session with code", 404);
    }

    // See state
    if (session.state === "inactive" || session.state === "active") {
        throw new ErrorStatus("Session is already active", 400);
    }

    // Create association
    const sessionParticipant = new SessionParticipant({
        sessionId: session.id,
        userId,
        role: "participant",
    });
    await sessionParticipant.save();

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
    const token = await signSessionToken(
        session.id,
        userId,
        sessionParticipant.role
    );
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
