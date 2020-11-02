import {
    Group,
    NotificationSettings,
    Quiz,
    Session,
    Token,
    User,
    UserState,
} from "../models";
import { Op } from "sequelize";
import { firebaseTokenValid, sendMessage } from "../helpers/message";
import ErrorStatus from "../helpers/error";
import { buildSessionMessage } from "./notification_firebase";

/**
 * Adds a firebase token to a user.
 * @param userId
 * @param token
 */
export const addToken = async (
    userId: number,
    token: string,
    oldToken?: string
) => {
    const tokenValid = await firebaseTokenValid(token);
    if (!tokenValid) {
        throw new ErrorStatus("Firebase token is not valid", 400);
    }

    try {
        if (!oldToken) {
            // New token
            await Token.upsert({
                token: token,
                userId,
                scope: "firebase",
            });
        } else {
            // Old token exists
            const res = await Token.update(
                {
                    token,
                },
                {
                    where: {
                        userId,
                        token: oldToken,
                        scope: "firebase",
                    },
                }
            );
            if (res[0] != 1) {
                throw new ErrorStatus("Old token does not exist", 400);
            }
        }
    } catch (err) {
        if (err.parent.code === "23505") {
            throw new ErrorStatus("Token already exists", 400);
        }
        throw err;
    }
};

/**
 * Removes token of user
 * @param userId
 * @param token
 */
export const deleteTokenOfUser = async (userId: number, token: string) => {
    await Token.destroy({ where: { userId, token, scope: "firebase" } });
};

/**
 * Removes a token.
 * @param tokenId
 */
export const removeToken = async (token: string) => {
    await Token.destroy({ where: { scope: "firebase", token } });
};

/**
 * Updates a token.
 * @param token Token object
 * @param newValue New value of token
 */
export const updateToken = async (token: Token, newValue: string) => {
    token.token = newValue;
    await token.save();
};

/**
 * Update user's notification state.
 * @param opts
 */
export const updateNotificationState = async (
    userId: number,
    opts: { free: boolean; calendarFree: boolean }
) => {
    const [record] = await UserState.upsert(
        {
            userId,
            free: opts.free,
            calendarFree: opts.calendarFree,
        },
        { returning: true }
    );
    return record;
};

/**
 * Updates user's notification settings.
 * @param userId
 * @param opts
 */
export const updateNotificationSettings = async (userId: number, opts: any) => {
    // Location
    if (
        opts.location === undefined ||
        opts.location.lat === undefined ||
        opts.location.lon === undefined
    ) {
        opts.location = null;
    } else {
        const { lat, lon } = opts.location;
        opts.location = { lat, lon };
    }

    // Update
    const [record] = await NotificationSettings.upsert(
        {
            userId,
            ...opts,
        },
        { returning: true }
    );
    return record;
};

/**
 * Gets the user's notification settings.
 */
export const getNotificationSettings = async (userId: number) => {
    return await NotificationSettings.findOrCreate({ where: { userId } });
};

// Day names
const WEEKDAYS = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Monday",
];

/**
 * This function gets called on session creation for the purpose of notifying
 * users.
 * @param session The session
 */
export const sendSessionCreationNotification = async (
    initiatorId: number,
    session: Session
) => {
    // Self paced alone, nothing to do
    if (session.type === "self paced" && !session.isGroup) {
        return;
    }

    // Get group ID
    const groupId = session.groupId;

    // Query for group users
    // @ts-ignore
    const group = await Group.findByPk(groupId, {
        include: [
            {
                model: User,
                attributes: ["id"],
                // Is member
                through: { where: { role: "member" } },
                // Cannot be initiator
                where: {
                    id: { [Op.not]: initiatorId },
                },
                include: [
                    // Current user state
                    {
                        model: UserState,
                        required: false,
                    },
                    // User's notification settings
                    {
                        model: NotificationSettings,
                        required: true,
                    },
                    // User tokens
                    {
                        model: Token,
                        require: true,
                        where: { scope: "firebase" },
                        attributes: ["token"],
                    },
                    // The quiz
                    {
                        model: Quiz,
                        require: true,
                        where: { id: session.quizId },
                        attributes: ["id", "title"],
                    },
                ],
            },
        ],
    });

    // Get list of users
    const users = await filterUsers(group.Users, session);
    const tokens = users
        .map((user) => user.Tokens.map((token) => token.token))
        .flat();

    const type = session.type === "live" ? "live" : "smart";
    const message = buildSessionMessage(
        "SESSION_START",
        {
            quizId: session.quizId,
        },
        `New ${type} quiz session started`,
        `A new session for the quiz "${group.Quizzes[0].title}" has been started, click to join`,
        tokens
    );
    await sendMessage(message);
};

// Filter available users
const filterUsers = async (users: User[], session: Session) => {
    // Notification settings does not exist
    for (const user of users) {
        if (!user.NotificationSettings) {
            user.NotificationSettings = await NotificationSettings.create({
                userId: user.id,
            });
        }
    }

    // Get all users who have completed session
    let excluded: number[] = [];
    if (session.type === "self paced") {
        const sessions = await Session.findAll({
            attributes: ["id"],
            where: { quizId: session.quizId, type: "self paced" },
            include: [
                {
                    // @ts-ignore
                    model: User,
                    required: false,
                    attributes: ["id"],
                    // User was participant and completed
                    through: {
                        where: { role: "participant", state: "complete" },
                        attributes: ["id", "role", "state"]
                    },
                },
            ],
        });
        excluded = sessions
            .map((session) => session.Users.map((user) => user.id))
            .flat();
    }

    return users.filter((user) => {
        // Excluded since they have completed session
        if (excluded.includes(user.id)) return false;

        // No token
        if (user.Tokens.length === 0) return false;

        // Current date
        const date = new Date();
        // Get day of week
        const dateLocal = date.toLocaleDateString("en-US", {
            timeZone:
                user.NotificationSettings.timezone ?? "Australia/Melbourne",
            weekday: "long",
        });
        if (!user.NotificationSettings.days[WEEKDAYS.indexOf(dateLocal)]) {
            return false;
        }

        // todo: notification count check

        // Now check user state
        if (user.UserState) {
            if (session.type === "live") {
                // Live
                return user.NotificationSettings.calendarLive;
            } else {
                // Self paced
                if (user.UserState.calendarFree) {
                    return user.UserState.free;
                } else {
                    if (user.NotificationSettings.calendarSelfPaced) {
                        // User indicated that they're ok with notifications
                        // when they have item on calendar
                        return user.UserState.free;
                    } else {
                        return false;
                    }
                }
            }
        }

        // User has no state, true
        return true;
    });
};
