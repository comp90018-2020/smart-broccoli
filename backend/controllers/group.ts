import { Op } from "sequelize";
import ErrorStatus from "../helpers/error";
import { Group, User, UserGroup } from "../models";

/**
 * Get groups of user.
 * @param userId ID of user
 */
export const getGroups = async (userId: number) => {
    // Get user's groups
    const user = await User.findByPk(userId);
    const groups = await user.getGroups({
        attributes: ["id", "name", "createdAt", "updatedAt"],
    });

    // Add role
    return groups.map((group) => {
        // @ts-ignore
        const { UserGroup, ...rest } = group.toJSON();
        return { ...rest, role: group.UserGroup.role };
    });
};

/**
 * Get group by ID.
 * @param userId
 * @param groupId
 */
export const getGroup = async (userId: number, groupId: number) => {
    // Get group and associated users
    // TODO: quiz, quiz sessions
    const group = await Group.findByPk(groupId, {
        // @ts-ignore
        include: {
            model: User,
            required: true,
            attributes: ["id", "updatedAt", "name"],
        },
    });
    if (!group.Users.find((user) => user.id === userId)) {
        const err = new ErrorStatus("User not part of group", 403);
        throw err;
    }
    return {
        ...group.toJSON(),
        Users: group.Users.map((user) => {
            // @ts-ignore
            const { UserGroup, ...rest } = user.toJSON();
            return { ...rest, role: user.UserGroup.role };
        }),
    };
};

/**
 * Create group
 * @param userId
 * @param info Group information
 */
export const createGroup = async (userId: number, name: string) => {
    // Create new group
    const group = new Group({
        name,
    });
    try {
        await group.save();
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
export const joinGroup = async (userId: number, name: string) => {
    // Find group
    const group = await Group.findOne({
        where: {
            name: name.toLowerCase(),
        },
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
        const err = new ErrorStatus("Already member of group", 404);
        throw err;
    }

    // Create association
    await UserGroup.create({
        userId,
        groupId: group.id,
        role: "member",
    });
    return group;
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
    if (name) {
        group.name = name;
    }

    try {
        return await group.save();
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
    await Group.destroy({ where: { id: groupId } });
};
