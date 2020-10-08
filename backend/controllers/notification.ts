import sequelize, { Token } from "../models";
import sendFirebaseMessage, { firebaseTokenValid } from "../helpers/message";
import ErrorStatus from "../helpers/error";

/**
 * Sends a message to the specified recipient.
// Adapted from:
// https://github.com/COMP30022-Russia/COMP30022_Server
 * @param message The message to be sent.
 * @param userID The ID(s) of the recipient.
 */
export const sendMessage = async (message: any, tokens: Token[]) => {
    // Only send in production environment
    if (process.env.NODE_ENV !== "production") {
        // Output message to console if in development environment
        if (process.env.NODE_ENV === "development") {
            console.info(message);
        }
        return;
    }

    // Stop if there are no tokens
    if (tokens.length === 0) {
        return;
    }

    try {
        // Send the message with given tokens
        const response = await sendFirebaseMessage(
            message,
            tokens.map((t) => t.token)
        );

        for (const [index, result] of response.results.entries()) {
            // Replace token, if applicable
            if (result.canonicalRegistrationToken !== tokens[index].token) {
                await updateToken(
                    tokens[index],
                    result.canonicalRegistrationToken
                );
            }

            // Remove token, if applicable
            if (result.error) {
                if (
                    result.error.code ===
                    "messaging/registration-token-not-registered"
                ) {
                    await removeToken(tokens[index]);
                } else {
                    console.error(result.error);
                }
            }
        }
    } catch (err) {
        console.error(err);
    }
};

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
export const removeToken = async (token: Token) => {
    await token.destroy();
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