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
    notify: boolean = true,
    ttlSeconds: number = 5 * 60
): admin.messaging.MulticastMessage => {
    const message: admin.messaging.MulticastMessage = {
        data: {
            type,
            data: JSON.stringify(content),
        },
        android: {
            ttl: ttlSeconds * 1000,
            priority: "normal",
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
    if (notify) {
        message["notification"] = {
            title: title,
            body: body,
        };
        message["android"]["notification"] = { clickAction: type };
    }
    return message;
};
