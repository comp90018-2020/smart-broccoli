// Firebase messaging
// Adapted from:
// https://github.com/COMP30022-Russia/COMP30022_Server/blob/master/helpers/notifications.ts
import * as admin from "firebase-admin";

// Initalise firebase in production environments
// From https://firebase.google.com/docs/admin/setup#initialize_the_sdk
if (process.env.NODE_ENV === "production") {
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
export const firebaseTokenValid = async(token: string) => {
    try {
        await admin.auth().verifyIdToken(token, true);
        return true;
    } catch (err) {
        return false;
    }
}

/**
 * Sends a message to the socket service and FCM.
 * @param message The payload to be sent.
 * @param tokens List of device tokens.
 * @return Promise object representing the response.
 */
export default async function (
    tokens: string[],
    message: any,
    timeToLive?: number
): Promise<admin.messaging.MessagingDevicesResponse> {
    // Send the message and return the response
    return new Promise<admin.messaging.MessagingDevicesResponse>(
        (resolve, reject) => {
            admin
                .messaging()
                .sendToDevice(tokens, message, { timeToLive })
                .then((response: admin.messaging.MessagingDevicesResponse) => {
                    resolve(response);
                })
                .catch((err: Error) => {
                    reject(err);
                });
        }
    );
}

/**
 * Builds an Firebase android notification message.
 * @param title Title of message.
 * @param body Body of message.
 */
export const buildAndroidNotificationMessage = (
    title: string,
    body: string
) => {
    return {
        notification: {
            title,
            body,
        },
    };
};

/**
 * Builds a Firebase data message.
 * @param type The type of the message.
 * @param content Content of message.
 */
export const buildDataMessage = (type: string, content: any) => {
    return {
        data: {
            type,
            data: JSON.stringify(content),
        },
    };
};
