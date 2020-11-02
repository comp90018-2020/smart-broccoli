// File for building notification message
import * as admin from "firebase-admin";

/**
 * Builds a Firebase data message.
 * @param type The type of the message.
 * @param content Content of message.
 */
export const buildSessionMessage = (
    type: string,
    content: any,
    title: string,
    body: string,
    tokens: string[],
    ttlSeconds: number = 5 * 60
): admin.messaging.MulticastMessage => {
    return {
        data: {
            type,
            data: JSON.stringify(content),
        },
        notification: {
            title: title,
            body: body,
        },
        android: {
            ttl: ttlSeconds * 1000,
            priority: "normal",
            notification: {
                clickAction: type,
            },
        },
        apns: {
            payload: {
                aps: {
                    category: type,
                },
            },
        },
        tokens,
    };
};
