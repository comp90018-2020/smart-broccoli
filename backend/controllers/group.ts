import { Op, Transaction } from "sequelize";
import ErrorStatus from "../helpers/error";
import sequelize, { Group, Session, User, UserGroup, Quiz } from "../models";
import {
    getGroupMemberTokens,
    sendGroupDeleteNotification,
    sendGroupUpdateNotification,
} from "./notification_group";

/**
 * Ensure that user is group owner.
 * @param userId
 * @param groupId
 */
export const assertGroupOwnership = async (userId: number, groupId: number) => {
    // Check whether caller is owner
    const isOwner = await UserGroup.count({
        where: { userId, groupId, role: "owner" },
    });
    if (!isOwner) {
        throw new ErrorStatus("Cannot perform group action", 403);
    }
};

/**
 * Create default group for user.
 * @param user User object
 */
export const createDefaultGroup = (
    userId: number,
    transaction: Transaction
) => {
    return createGroupHelper(userId, null, true, transaction);
};

/**
 * Get groups of user.
 * @param user
 */
export const getGroups = async (user: User) => {
    // Get groups
    const groups = await user.getGroups({
        include: [
            {
                // @ts-ignore
                model: User,
                // Owner name if default group
                through: { where: { role: "owner" }, attributes: [] },
                attributes: ["name"],
                required: true,
            },
        ],
    });

    return groups.map((group) => {
        // @ts-ignore
        const { UserGroup, Users, ...rest } = group.toJSON();
        return {
            ...rest,
            // Include owner's username if default group
            name: group.defaultGroup ? group.Users[0].name : group.name,
            // Add role
            role: group.UserGroup.role,
        };
    });
};

/**
 * Get group.
 * @param userId
 * @param groupId
 */
export const getGroup = async (user: User, groupId: number) => {
    // Get group
    const groupQuery = await user.getGroups({
        where: { id: groupId },
        include: [
            {
                // @ts-ignore Typing errors due to model
                model: User,
                // Owner name if default group
                through: { where: { role: "owner" }, attributes: [] },
                attributes: ["name"],
                required: true,
            },
        ],
    });
    if (groupQuery.length === 0) {
        throw new ErrorStatus("Group cannot be accessed", 404);
    }

    // Get role
    const group = groupQuery[0];
    const groupJSON: any = group.toJSON();
    delete groupJSON["Users"];
    delete groupJSON["UserGroup"];
    return {
        ...groupJSON,
        role: group.UserGroup.role,
        name: group.defaultGroup ? group.Users[0].name : group.name,
    };
};

/**
 * Get list of group members.
 * @param userId
 * @param groupId
 */
export const getGroupMembers = async (userId: number, groupId: number) => {
    // Get group and associated users
    const group = await Group.findByPk(groupId, {
        attributes: ["id"],
        // @ts-ignore
        include: {
            model: User,
            required: true,
            attributes: ["id", "updatedAt", "name", "pictureId"],
            through: { attributes: ["role"] },
        },
    });
    if (!group) {
        throw new ErrorStatus("Group not found", 404);
    }
    if (!group.Users.find((user) => user.id === userId)) {
        throw new ErrorStatus("User not part of group", 403);
    }

    return group.Users.map((user) => {
        const userJSON: any = user.toJSON();
        delete userJSON["UserGroup"];
        return { ...userJSON, role: user.UserGroup.role };
    });
};

/**
 * Create group helper function.
 * @param userId
 * @param name Name of group
 * @param defaultGroup Whether it's the user's default group
 * @param transaction
 */
const createGroupHelper = async (
    userId: number,
    name: string,
    defaultGroup: boolean = false,
    transaction: Transaction
) => {
    // Create new group
    let group = new Group({
        name,
        defaultGroup,
    });

    try {
        // Save group
        group = await group.save({ transaction });

        // Generate first code
        await regenerateCodeHelper(group, transaction);

        // Add association
        await UserGroup.create(
            {
                userId,
                groupId: group.id,
                role: "owner",
            },
            { transaction }
        );

        return group;
    } catch (err) {
        throw err;
    }
};

/**
 * Create group
 * @param userId
 * @param info Group information
 */
export const createGroup = async (
    userId: number,
    name: string,
    defaultGroup: boolean = false
) => {
    try {
        // Create group
        return await sequelize.transaction(async (transaction) => {
            return await createGroupHelper(
                userId,
                name,
                defaultGroup,
                transaction
            );
        });
    } catch (err) {
        if (err.parent.code === "23505") {
            const param = err.parent.constraint.split("_")[1];
            const payload = [
                {
                    msg: "Uniqueness constraint failure",
                    location: "body",
                    param,
                },
            ];
            throw new ErrorStatus(err.message, 409, payload);
        }
        throw err;
    }
};

/**
 * Join a group as a participant.
 * @param name Name of group
 */
export const joinGroup = async (
    userId: number,
    opts: { name?: string; code?: string }
) => {
    // Name or code
    let query = {};
    if (opts.name) {
        query = { name: { [Op.iLike]: opts.name } };
    } else if (opts.code) {
        query = { code: opts.code };
    } else {
        throw new ErrorStatus("No name or code provided", 400);
    }

    // Find group
    const group = await Group.findOne({
        where: query,
        // Include user
        include: [
            {
                // @ts-ignore Typing error
                // Model instantiation was derived from:
                // https://sequelize.org/master/manual/typescript.html
                model: User,
                where: { id: userId },
                through: { attributes: [] },
                required: false,
                attributes: ["id"],
            },
        ],
    });
    if (!group) {
        throw new ErrorStatus("Group not found", 404);
    }

    // Already part of group?
    if (group.Users.length > 0) {
        throw new ErrorStatus("Already member of group", 422);
    }

    // Create association
    await UserGroup.create({
        userId,
        groupId: group.id,
        role: "member",
    });

    // Send firebase notification
    if (process.env.NODE_ENV === "production") {
        sendGroupUpdateNotification(userId, group.id, "GROUP_MEMBER_UPDATE");
    } else {
        await sendGroupUpdateNotification(
            userId,
            group.id,
            "GROUP_MEMBER_UPDATE"
        );
    }

    const groupJSON: any = group.toJSON();
    groupJSON.role = "member";
    delete groupJSON["Users"];
    return groupJSON;
};

const CHARSET =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

/**
 * Generates codes to specified length.
 * @param length
 */
const generateCode = (length: number) => {
    return [...Array(length)]
        .map(
            () =>
                CHARSET[Math.floor(Math.random() * Math.floor(CHARSET.length))]
        )
        .join("");
};

/**
 * Regenerate code.
 * @param groupId
 */
const regenerateCodeHelper = async (
    group: Group,
    transaction?: Transaction
) => {
    let attempt = 0;

    // Regenerate until good
    while (true) {
        try {
            group.code = generateCode(6);
            return await group.save({ transaction });
        } catch (err) {
            // continue
            attempt += 1;
            if (attempt > 5) {
                // group may no longer exist
                return null;
            }
        }
    }
};

/**
 * Regenerate code helper.
 * @param user User object
 * @param groupId
 */
export const regenerateCode = async (userId: number, groupId: number) => {
    // Find group
    const group = await Group.findByPk(groupId, {
        attributes: ["id", "code"],
        include: [
            {
                // @ts-ignore
                model: User,
                required: true,
                attributes: [],
                through: { where: { role: "owner" } },
                where: { id: userId },
            },
        ],
    });
    if (!group) {
        throw new ErrorStatus("Group cannot be accessed", 403);
    }

    const groupUpdated = await regenerateCodeHelper(group);
    const groupJSON: any = groupUpdated.toJSON();
    groupJSON.role = "owner";
    delete groupJSON["Users"];
    delete groupJSON["UserGroup"];
    return groupJSON;
};

/**
 * Leave specified group.
 * @param groupId
 * @param userId Caller's user ID
 */
export const leaveGroup = async (groupId: number, userId: number) => {
    // Find user group
    const userGroup = await UserGroup.findOne({
        where: { userId, groupId },
        attributes: ["id", "role"],
    });
    if (!userGroup) {
        throw new ErrorStatus("User is not member of group", 400);
    }

    // Owner cannot leave
    if (userGroup.role === "owner") {
        // Can be expanded later if there are multiple owners
        throw new ErrorStatus("Last owner of group cannot leave", 400);
    }

    // Send firebase notification
    if (process.env.NODE_ENV === "production") {
        sendGroupUpdateNotification(userId, groupId, "GROUP_MEMBER_UPDATE");
    } else {
        await sendGroupUpdateNotification(
            userId,
            groupId,
            "GROUP_MEMBER_UPDATE"
        );
    }

    // Destroy association
    return await userGroup.destroy();
};

/**
 * Delete member.
 * @param groupId
 * @param userId ID of member to delete
 */
export const deleteMember = async (
    callerId: number,
    groupId: number,
    userId: number
) => {
    // Ensure that caller is owner
    await assertGroupOwnership(callerId, groupId);

    const res = await UserGroup.destroy({
        where: {
            groupId,
            userId,
            role: "member",
        },
    });
    if (res != 1) {
        throw new ErrorStatus("Cannot delete member", 400);
    }

    // Send firebase notification
    if (process.env.NODE_ENV === "production") {
        sendGroupUpdateNotification(userId, groupId, "GROUP_MEMBER_UPDATE");
    } else {
        await sendGroupUpdateNotification(
            userId,
            groupId,
            "GROUP_MEMBER_UPDATE"
        );
    }
};

/**
 * Update group.
 * @param group
 */
export const updateGroup = async (
    userId: number,
    groupId: number,
    name: string
) => {
    // Find group
    const group = await Group.findByPk(groupId, {
        include: [
            {
                // @ts-ignore
                model: User,
                attributes: [],
                through: { where: { role: "owner" }, attributes: [] },
                where: { id: userId },
                required: true,
            },
        ],
    });
    if (!group) {
        throw new ErrorStatus("Group cannot be accessed", 403);
    }
    if (name && !group.defaultGroup) {
        group.name = name;
    }

    try {
        await group.save();
        const groupJSON: any = group.toJSON();

        // Send firebase notification
        if (process.env.NODE_ENV === "production") {
            sendGroupUpdateNotification(userId, groupId, "GROUP_UPDATE");
        } else {
            await sendGroupUpdateNotification(userId, groupId, "GROUP_UPDATE");
        }

        delete groupJSON["Users"];
        return groupJSON;
    } catch (err) {
        if (err.parent.code === "23505") {
            const param = err.parent.constraint.split("_")[1];
            const payload = [
                {
                    msg: "Uniqueness constraint failure",
                    location: "body",
                    param,
                },
            ];
            throw new ErrorStatus(err.message, 409, payload);
        }
        throw err;
    }
};

/**
 * Delete group by ID.
 * @param groupId
 */
export const deleteGroup = async (userId: number, groupId: number) => {
    // Check whether caller is owner
    await assertGroupOwnership(userId, groupId);

    // Get user tokens (otherwise cannot get when group is deleted!)
    const tokens = await getGroupMemberTokens(userId, groupId);

    // Find group
    // @ts-ignore
    const group = await Group.findByPk(groupId, {
        attributes: ["id"],
        where: { defaultGroup: false },
        include: [
            {
                model: Quiz,
                required: false,
                attributes: ["id"],
                include: [
                    {
                        model: Session,
                        required: false,
                        where: { state: { [Op.or]: ["waiting", "active"] } },
                        attributes: ["id"],
                    },
                ],
            },
        ],
    });
    if (!group) {
        throw new ErrorStatus("Group cannot be deleted", 400);
    }
    // If more than 1 session is active
    if (group.Quizzes.map((quiz) => quiz.Sessions).flat().length > 0) {
        throw new ErrorStatus(
            "Group still has quizzes with active sessions",
            400
        );
    }

    // Destroy group
    await group.destroy();

    // Send firebase notification
    if (process.env.NODE_ENV === "production") {
        sendGroupDeleteNotification(groupId, tokens);
    } else {
        await sendGroupDeleteNotification(groupId, tokens);
    }
};

/**
 * Get quizzes of group.
 * @param group Group that user is member of
 */
export const getGroupQuizzes = async (userId: number, groupId: number) => {
    // Get group and role
    const group = await Group.findByPk(groupId, {
        attributes: ["id"],
        include: [
            {
                // @ts-ignore
                model: User,
                required: true,
                attributes: ["id"],
                where: { id: userId },
                through: { attributes: ["role"] },
            },
        ],
    });
    if (!group) {
        throw new ErrorStatus("Group does not exist", 404);
    }

    // Only active quizzes for members
    const role = group.Users[0].UserGroup.role;
    const quizzes = await group.getQuizzes({
        where: role === "owner" ? undefined : { active: true },
        include: [
            {
                // @ts-ignore
                model: Session,
                required: false,
                where: { state: { [Op.not]: "lost" } },
                include: [
                    {
                        // @ts-ignore
                        model: User,
                        required: false,
                        attributes: ["id"],
                        through: { attributes: ["state"] },
                        where: { id: userId },
                    },
                ],
            },
        ],
    });

    return quizzes.map((quiz) => {
        return {
            ...quiz.toJSON(),
            role,
            // Whether user has completed quiz
            complete:
                quiz.Sessions.find(
                    (session) =>
                        session.Users.length > 0 &&
                        session.Users[0].SessionParticipant.state === "complete"
                ) != null,
            Sessions: quiz.Sessions.filter(
                (session) =>
                    session.state === "waiting" || session.Users.length > 0
            ).map((session) => {
                // @ts-ignore
                const sessionJSON: any = session.toJSON();
                delete sessionJSON["Users"];
                return sessionJSON;
            }),
        };
    });
};
