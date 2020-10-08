import { Token } from "../models";
import sendFirebaseMessage, { firebaseTokenValid } from "../helpers/message";
import ErrorStatus from "helpers/error";

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
export const addToken = async (userId: number, token: string) => {
    const tokenValid = await firebaseTokenValid(token);
    if (!tokenValid) {
        throw new ErrorStatus("Firebase token is not valid", 400);
    }

    await Token.create({
        token: token,
        userId,
        scope: "firebase",
    });
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
