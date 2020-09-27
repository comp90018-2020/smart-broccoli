import { Op } from "sequelize";
import ErrorStatus from "../helpers/error";
import { Group, User, UserGroup } from "../models";

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
                where: { "$Users.UserGroup.role$": "owner" },
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
                    [Op.or]: [
                        { id: userId },
                        { "$Users.UserGroup.role$": "owner" },
                    ],
                },
                attributes: ["id", "name"],
                required: true,
            },
        ],
    });

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
        const err = new ErrorStatus("Group not found", 404);
        throw err;
    }
    if (!group.Users.find((user) => user.id === userId)) {
        const err = new ErrorStatus("User not part of group", 403);
        throw err;
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

    try {
        // Save group
        group = await group.save();

        // Generate first code
        await regenerateCode(group);
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
            const e = new ErrorStatus(err.message, 409, payload);
            throw e;
        }
        throw err;
    }

    // Add association
    await UserGroup.create({
        userId,
        groupId: group.id,
        role: "owner",
    });
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
        const err = new ErrorStatus("No name or code provided", 400);
        throw err;
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
        const err = new ErrorStatus("Group not found", 404);
        throw err;
    }

    // Already part of group?
    if (group.Users.length > 0) {
        const err = new ErrorStatus("Already member of group", 422);
        throw err;
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
export const regenerateCode = async (group: Group) => {
    let attempt = 0;

    // Regenerate until good
    while (true) {
        try {
            group.code = generateCode(6);
            await group.save();
            const groupJSON: any = group.toJSON();
            groupJSON.role = "owner";
            delete groupJSON["Users"];
            return groupJSON;
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
 * Get group by id and verify that user is creator.
 * @param userId
 * @param groupId
 * @param role Role of user
 */
export const getGroupAndVerifyRole = async (
    userId: number,
    groupId: number,
    role: string
) => {
    const group = await Group.findOne({
        where: {
            id: groupId,
            [Op.or]:
                role === "owner"
                    ? // Is owner
                      [{ "$Users.UserGroup.role$": "owner" }]
                    : // Owners are members also
                      [
                          { "$Users.UserGroup.role$": "owner" },
                          { "$Users.UserGroup.role$": "member" },
                      ],
        },
        include: [
            {
                // @ts-ignore Typing errors due to model
                model: User,
                where: {
                    id: userId,
                },
                attributes: ["id"],
                required: true,
            },
        ],
    });

    if (!group) {
        const err = new ErrorStatus(
            "User does not have privileges to access specified group",
            403
        );
        throw err;
    }
    return group;
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
        const err = new ErrorStatus("Last owner of group cannot leave", 400);
        throw err;
    }

    // Destroy association
    const res = await UserGroup.destroy({
        where: {
            groupId,
            userId,
        },
    });
    if (res != 1) {
        const err = new ErrorStatus("Cannot leave group", 400);
        throw err;
    }
};

/**
 * Delete member.
 * @param groupId
 * @param userId ID of member to delete
 */
export const deleteMember = async (groupId: number, userId: number) => {
    const res = await UserGroup.destroy({
        where: {
            groupId,
            userId,
            role: "member",
        },
    });
    if (res != 1) {
        const err = new ErrorStatus("Cannot delete member", 400);
        throw err;
    }
};

/**
 * Update group.
 * @param group
 */
export const updateGroup = async (group: Group, name: string) => {
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
            const e = new ErrorStatus(err.message, 409, payload);
            throw e;
        }
        throw err;
    }
};

/**
 * Delete group by ID.
 * @param groupId
 */
export const deleteGroup = async (groupId: number) => {
    const res = await Group.destroy({
        where: { id: groupId, defaultGroup: false },
    });
    if (res != 1) throw new ErrorStatus("Cannot delete group", 400);
};
