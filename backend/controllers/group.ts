import { Op, Transaction } from "sequelize";
import ErrorStatus from "../helpers/error";
import sequelize, { Group, Session, User, UserGroup } from "../models";

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
export const createDefaultGroup = async (userId: number, transaction: Transaction) => {
    return await createGroup(userId, null, transaction, true);
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
                //@ts-ignore
                model: User,
                // Owner name if default group
                through: { where: { role: "owner" }, attributes: ["role"] },
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
                through: { where: { role: "owner" }, attributes: ["role"] },
                attributes: ["id", "name"],
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
    return {
        ...groupJSON,
        role: group.UserGroup.role,
        name: group.defaultGroup
            ? group.Users.find((u) => u.UserGroup.role === "owner").name
            : group.name,
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
            attributes: ["id", "updatedAt", "name"],
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
 * Create group
 * @param userId
 * @param info Group information
 */
export const createGroup = async (
    userId: number,
    name: string,
    transaction: Transaction = null,
    defaultGroup: boolean = false
) => {
    // Create new group
    let group = new Group({
        name,
        defaultGroup,
    });

    // No transaction
    if (!transaction) {
        transaction = await sequelize.transaction();
    }

    try {
        // Save group
        group = await group.save({ transaction: transaction });

        // Generate first code
        await regenerateCodeHelper(group, transaction);

        // Add association
        await UserGroup.create(
            {
                userId,
                groupId: group.id,
                role: "owner",
            },
            { transaction: transaction }
        );

        await transaction.commit();
    } catch (err) {
        await transaction.rollback();

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

    return group;
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
                attributes: ['id']
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
    // Possible future expansion: manager/owner promotions
    // Non-optimised checking
    const userGroup = await UserGroup.findAll({
        where: { groupId, role: "owner" },
    });
    if (userGroup.length === 1 && userGroup[0].userId === userId) {
        throw new ErrorStatus("Last owner of group cannot leave", 400);
    }

    // Destroy association
    const res = await UserGroup.destroy({
        where: {
            groupId,
            userId,
        },
    });
    if (res != 1) {
        throw new ErrorStatus("Cannot leave group", 400);
    }
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

    // Destroy group
    const res = await Group.destroy({
        where: { id: groupId, defaultGroup: false },
    });
    if (res != 1) throw new ErrorStatus("Cannot delete group", 400);
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
