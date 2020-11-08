import { sendMessage } from "../helpers/message";
import { Op } from "sequelize";
import { User, Group, Token } from "../models";
import { buildDataMessage } from "./notification_firebase";

// Sends group member update notifications
// TODO: refactor along with notification_quiz
export const sendGroupUpdateNotification = async (
    initiatorId: number,
    groupId: number,
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
            groupId: groupId,
        },
        tokens
    );
    await sendMessage(dataMessage);
};

// Used to send group deletion notification
export const sendGroupDeleteNotification = async (
    groupId: number,
    tokens: string[]
) => {
    // Build and send
    const dataMessage = buildDataMessage(
        "GROUP_DELETE",
        {
            groupId: groupId,
        },
        tokens
    );
    await sendMessage(dataMessage);
};

// Get tokens of group members
export const getGroupMemberTokens = async (
    initiatorId: number,
    groupId: number
) => {
    // @ts-ignore
    const group = await Group.findByPk(groupId, {
        include: [
            {
                model: User,
                attributes: ["id"],
                required: false,
                // Cannot be initiator
                where: initiatorId
                    ? {
                          id: { [Op.not]: initiatorId },
                      }
                    : undefined,
                include: [
                    // User tokens
                    {
                        model: Token,
                        require: false,
                        where: { scope: "firebase" },
                        attributes: ["token"],
                    },
                ],
            },
        ],
    });

    return group.Users.map((user) =>
        user.Tokens.map((token) => token.token)
    ).flat();
};
