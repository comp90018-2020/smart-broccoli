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
    // Get tokens of group members who is not initiator
    const tokens = await getGroupMemberTokens(initiatorId, groupId);

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
