import { NotificationSettings, Token, UserState } from "../models";
import { firebaseTokenValid } from "../helpers/message";
import ErrorStatus from "../helpers/error";

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
        opts.location.lon === undefined ||
        opts.location.name === undefined
    ) {
        opts.location = null;
    } else {
        const { lat, lon, name } = opts.location;
        opts.location = { lat, lon, name };
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
