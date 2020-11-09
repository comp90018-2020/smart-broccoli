// File for building notification message
import * as admin from "firebase-admin";

/**
 * Builds
 */
export const buildDataMessage = (
    type: string,
    content: any,
    tokens: string[]
): admin.messaging.MulticastMessage => {
    return {
        data: { type, data: JSON.stringify(content) },
        tokens,
    };
};

/**
 * Builds a Firebase data message.
 */
export const buildNotificationMessage = (
    type: string,
    content: any,
    title: string,
    body: string,
    tokens: string[],
    notification: boolean = true,
    ttlSeconds: number = 5 * 60
): admin.messaging.MulticastMessage => {
    const message: admin.messaging.MulticastMessage = {
        data: {
            type,
            data: JSON.stringify(content),
        },
        android: {
            ttl: ttlSeconds * 1000,
            priority: "high",
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
    if (notification) {
        message["notification"] = {
            title: title,
            body: body,
        };
    }
    return message;
};
