// Firebase messaging
// Adapted from:
// https://github.com/COMP30022-Russia/COMP30022_Server/blob/master/helpers/notifications.ts
import { removeToken } from "../controllers/notification";
import * as admin from "firebase-admin";

// Initalise firebase in production environments
// From https://firebase.google.com/docs/admin/setup#initialize_the_sdk
if (process.env.NODE_ENV === "production" && !process.env.FIREBASE_PROJECT_ID) {
    console.error("Firebase configurations not set");
    process.exit(1);
}
// If project ID is set, initialise firebase
if (process.env.FIREBASE_PROJECT_ID) {
    admin.initializeApp({
        credential: admin.credential.cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
        }),
        databaseURL: process.env.FIREBASE_DATABASE_URL,
    });
}

/**
 * Determines whether firebase token is valid.
 * @param token
 */
export const firebaseTokenValid = async (token: string) => {
    try {
        if (process.env.NODE_ENV !== "production") {
            return true;
        }
        await admin.auth().verifyIdToken(token, true);
        return true;
    } catch (err) {
        return false;
    }
};

/**
 * Sends a message to the specified recipient.
 * Adapted from:
 * https://github.com/COMP30022-Russia/COMP30022_Server
 * @param message The message to be sent.
 * @param userID The ID(s) of the recipient.
 */
export const sendMessage = async (
    message: admin.messaging.MulticastMessage
) => {
    if (message.tokens.length === 0) return;
    if (!process.env.FIREBASE_PROJECT_ID) {
        console.log(message);
        return;
    }

    // Log the message
    console.log(message);

    try {
        // Send the message with given tokens
        const messaging = admin.messaging();
        const response = await messaging.sendMulticast(message);

        for (const [index, result] of response.responses.entries()) {
            // Remove token, if applicable
            if (result.error) {
                if (
                    result.error.code ===
                    "messaging/registration-token-not-registered"
                ) {
                    await removeToken(message.tokens[index]);
                } else {
                    console.error(result.error);
                }
            }
        }
    } catch (err) {
        console.error(err);
    }
};
