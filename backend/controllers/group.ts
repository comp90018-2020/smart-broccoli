import { Op, Transaction } from "sequelize";
import ErrorStatus from "../helpers/error";
import Sequelize from "sequelize";
import sequelize, { Group, Session, User, UserGroup } from "../models";

/**
 * Get group of user.
 * @param user User object
 * @param groupId ID of target group
 */
const getGroupAndRole = async (user: User, groupId: number, role: string) => {
    const groupQuery = await user.getGroups({
        where: {
            id: groupId,
            [Op.or]:
                role === "owner"
                    ? // Is owner
                      [{ "$UserGroup.role$": "owner" }]
                    : // Owners are members also
                      [
                          { "$UserGroup.role$": "owner" },
                          { "$UserGroup.role$": "member" },
                      ],
        },
    });
    if (groupQuery.length === 0) {
        throw new ErrorStatus(
            "User does not have privilege to access group resource",
            403
        );
    }
    return { group: groupQuery[0], role: groupQuery[0].UserGroup.role };
};

/**
 * Ensure that user is group owner.
 * @param userId
 * @param groupId
 */
export const assertGroupOwnership = async (userId: number, groupId: number) => {
    // Check whether caller is owner
    const isOwner = await UserGroup.count({
        where: { userId: userId, groupId, role: "owner" },
    });
    if (!isOwner) {
        throw new ErrorStatus("Cannot perform group action", 403);
    }
};

/**
 * Create default group for user.
 * @param user User object
 */
export const createDefaultGroup = async (userId: number) => {
    return await createGroup(userId, null, true);
};

/**
 * Get groups of user.
 * @param user
 */
export const getGroups = async (user: User) => {
    // Get groups
    const groups = await user.getGroups({
        attributes: [
            "id",
            "name",
            "createdAt",
            "updatedAt",
            "defaultGroup",
            "code",
        ],
        include: [
            {
                //@ts-ignore
                model: User,
                through: { where: { role: "owner" } },
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
export const getGroup = async (userId: number, groupId: number) => {
    // Get group
    const group = await Group.findByPk(groupId, {
        include: [
            {
                // @ts-ignore Typing errors due to model
                model: User,
                where: {
                    [Op.or]: [{ id: userId }],
                },
                through: { where: { role: "owner" } },
                attributes: ["id", "name"],
                required: true,
            },
        ],
    });
    if (!group) {
        throw new ErrorStatus("Group cannot be accessed", 404);
    }

    // Get role
    const groupJSON: any = group.toJSON();
    delete groupJSON["Users"];
    return {
        ...groupJSON,
        role: group.Users.find((u) => u.id === userId).UserGroup.role,
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
        // @ts-ignore
        include: {
            model: User,
            required: true,
            attributes: ["id", "updatedAt", "name"],
        },
    });
    if (!group) {
        throw new ErrorStatus("Group not found", 404);
    }
    if (!group.Users.find((user) => user.id === userId)) {
        throw new ErrorStatus("User not part of group", 403);
    }

    return group.Users.map((user) => {
        // @ts-ignore
        const { UserGroup, ...rest } = user.toJSON();
        return { ...rest, role: user.UserGroup.role };
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
    defaultGroup: boolean = false
) => {
    // Create new group
    let group = new Group({
        name,
        defaultGroup,
    });

    const transaction = await sequelize.transaction();
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
                required: false,
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
export const regenerateCode = async (user: User, groupId: number) => {
    const { group } = await getGroupAndRole(user, groupId, "owner");
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
    user: User,
    groupId: number,
    name: string
) => {
    const { group } = await getGroupAndRole(user, groupId, "owner");
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
export const getGroupQuizzes = async (user: User, groupId: number) => {
    // Get group and role
    const { group, role } = await getGroupAndRole(user, groupId, "member");

    // Only active quizzes for members
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
                        where: { id: user.id },
                        through: { attributes: ["state"] },
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
