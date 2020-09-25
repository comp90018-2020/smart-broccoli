import { Op } from "sequelize";
import ErrorStatus from "../helpers/error";
import { Group, User, UserGroup } from "../models";

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
    await group.save();

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
