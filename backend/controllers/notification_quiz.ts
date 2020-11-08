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
    // Get tokens of group members who is not initiator
    const tokens = await getGroupMemberTokens(initiatorId, groupId);

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
