import {
    Group,
    NotificationSettings,
    Quiz,
    Session,
    Token,
    User,
    UserState,
    NotificationEntry,
} from "../models";
import { Op } from "sequelize";
import { firebaseTokenValid, sendMessage } from "../helpers/message";
import ErrorStatus from "../helpers/error";
import { buildNotificationMessage } from "./notification_firebase";
import { DateTime, Info } from "luxon";

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
            const [created] = await Token.upsert({
                token: token,
                userId,
                scope: "firebase",
            });
            return created;
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
                    returning: true,
                }
            );
            if (res[0] != 1) {
                throw new ErrorStatus("Old token does not exist", 400);
            }
            return res[1][0];
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
    const res = await NotificationSettings.findOrCreate({ where: { userId } });
    return res[0];
};

/**
 * This function gets called on session creation for the purpose of notifying
 * users.
 * @param session The session
 */
export const sendSessionCreationNotification = async (
    initiatorId: number,
    session: Session,
    quiz: Quiz
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
        attributes: ["id"],
        include: [
            {
                model: User,
                attributes: ["id"],
                required: false,
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
                        required: false,
                    },
                    // User tokens
                    {
                        model: Token,
                        require: false,
                        where: { scope: "firebase" },
                        attributes: ["token"],
                    },
                ],
            },
        ],
    });

    // Get list of users
    const allUsers = group.Users.filter((user) => user.Tokens.length > 0);
    // IDs of users who should not be messaged
    const noMessageUserIds = await noMessageUsers(session);

    // List of all users who should be messaged
    const messageUsers = allUsers.filter(
        (user) => !noMessageUserIds.includes(user.id)
    );
    // Fill in notification settings
    await fillNotificationSettings(messageUsers);
    // IDs of users who should receive a notification
    const notificationUsersIds = await notificationUsers(messageUsers, session);

    // Get tokens
    const dataTokens = messageUsers
        .filter((user) => !notificationUsersIds.includes(user.id))
        .map((user) => user.Tokens.map((token) => token.token))
        .flat();
    const notifyTokens = messageUsers
        .filter((user) => notificationUsersIds.includes(user.id))
        .map((user) => user.Tokens.map((token) => token.token))
        .flat();

    // Generate messages
    const type = session.type === "live" ? "live" : "smart";
    const dataMessage = buildNotificationMessage(
        "SESSION_START",
        {
            quizId: session.quizId,
            sessionId: session.id,
        },
        `${type == "live" ? "Live" : "Smart auto"} quiz session started`,
        `Join now! "${quiz.title}" is currently accepting participants`,
        dataTokens,
        false
    );
    const notificationMessage = buildNotificationMessage(
        "SESSION_START",
        {
            quizId: session.quizId,
            sessionId: session.id,
        },
        `${type == "live" ? "Live" : "Smart auto"} quiz session started`,
        `Join now! "${quiz.title}" is currently accepting participants`,
        notifyTokens,
        true
    );
    // And send
    await sendMessage(dataMessage);
    await sendMessage(notificationMessage);
};

// Fill notification settings
const fillNotificationSettings = async (users: User[]) => {
    // Notification settings does not exist
    for (const user of users) {
        if (!user.NotificationSetting) {
            user.NotificationSetting = new NotificationSettings();
        }
    }
};

// Filter to users who SHOULDN't have data message sent
const noMessageUsers = async (session: Session) => {
    // Get all users who have completed session
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
                        attributes: ["id", "role", "state"],
                    },
                },
            ],
        });
        return sessions
            .map((session) => session.Users.map((user) => user.id))
            .flat();
    }
    return [];
};

// Filter to users who SHOULD receive a notification
const notificationUsers = async (users: User[], session: Session) => {
    // Filter by state
    const stateFilteredUsers: User[] = users.filter((user) => {
        // Current date
        const date = DateTime.local().setZone(
            user.NotificationSetting.timezone ?? "Australia/Melbourne"
        );
        // Get day of week
        const dayOfWeek = date.weekdayLong;
        if (
            !user.NotificationSetting.days[
                Info.weekdays("long").indexOf(dayOfWeek)
            ]
        ) {
            return false;
        }

        // Now check user state
        if (user.UserState) {
            // If user's calendar is not free
            if (!user.UserState.calendarFree) {
                // And they do not want notifications when their calendar
                // is not free
                if (
                    (session.type === "live" &&
                        !user.NotificationSetting.calendarLive) ||
                    (session.type === "self paced" &&
                        !user.NotificationSetting.calendarSelfPaced)
                ) {
                    return false;
                }
            }
            // User indicated that they're ok with notifications
            // when they have item on calendar
            return user.UserState.free;
        }

        // User has no state, true
        return true;
    });

    // Filter/map to list of user ids who can be notified (or null)
    const notify: number[] = await Promise.all(
        stateFilteredUsers.map((user) => canNotifyAndSet(user))
    );
    // Now filter to users who can be notified and return their user IDs
    return stateFilteredUsers
        .filter((user) => notify.includes(user.id))
        .map((user) => user.id);
};

// Can notify user within bounds of user's notification limits?
// If so, add an entry
const canNotifyAndSet = async (user: User) => {
    // Start of day for user
    const startForUser = DateTime.local()
        .setZone(user.NotificationSetting.timezone ?? "Australia/Melbourne")
        .startOf("day");

    // Get notification entries with createdAt within 24 hours
    // https://stackoverflow.com/questions/52453374
    const notifications = await NotificationEntry.findAll({
        where: {
            userId: user.id,
            createdAt: { [Op.gt]: startForUser.toJSDate() },
        },
        order: [["time", "DESC"]],
    });

    // Max notification count per day
    if (
        user.NotificationSetting.maxNotificationsPerDay > 0 &&
        notifications.length >= user.NotificationSetting.maxNotificationsPerDay
    ) {
        return null;
    }

    // Look at last notification
    if (
        user.NotificationSetting.notificationWindow > 0 &&
        notifications.length > 0
    ) {
        const last: Date = notifications[0].time;
        // If (current - last).minutes < user setting, do not notify
        if (
            DateTime.local().diff(DateTime.fromJSDate(last)).minutes <
            user.NotificationSetting.notificationWindow
        ) {
            return null;
        }
    }

    // Add notification entry
    await NotificationEntry.create({ userId: user.id, time: new Date() });
    return user.id;
};
