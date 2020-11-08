import { sendMessage } from "../helpers/message";
import { buildDataMessage } from "./notification_firebase";
import { getGroupMemberTokens } from "./notification_group";

// Sends group member update notifications
// TODO: refactor along with notification_group
export const sendQuizUpdateNotification = async (
    initiatorId: number,
    groupId: number,
    quizId: number,
    type: string
) => {
    let tokens;
    try {
        // Get tokens of group members who is not initiator
        tokens = await getGroupMemberTokens(initiatorId, groupId);
    } catch (err) {
        console.error(err);
        return;
    }

    // Build and send
    const dataMessage = buildDataMessage(
        type,
        {
            groupId,
            quizId,
        },
        tokens
    );
    await sendMessage(dataMessage);
};
