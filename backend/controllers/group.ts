import ErrorStatus from "helpers/error";
import { Group, UserGroup } from "../models";

/**
 * Create group
 * @param userId
 * @param info Group information
 */
const createGroup = async (userId: number, info: any) => {
    // Create new group
    const group = new Group({});
    if (info.name) {
        group.name = info.name;
    }
    await group.save();

    // Add association
    const userGroup = new UserGroup({
        userId,
        groupId: group.id,
        type: "owner",
    });
};

const joinGroup = async (code: string) => {
    // Find
    const group = await Group.findOne({
        where: {},
    });
    if (!group) {
        const err = new ErrorStatus("Group not found", 404);
        throw err;
    }
};

/**
 * Get group by id and verify that user is creator.
 * @param userId
 * @param groupId
 */
const getGroupAndVerifyCreator = async (userId: number, groupId: number) => {
    // Find group
    const group = await Group.findByPk(groupId, {
        // @ts-ignore
        include: [{ model: UserGroup, required: true, where: { userId } }],
    });
    if (!group) {
        const err = new ErrorStatus("Group not found", 404);
        throw err;
    }

    // If owner is not correct
    // if (group.ownerId != userId) {
    //     const err = new ErrorStatus("User has no access", 403);
    //     throw err;
    // }
    return group;
};
