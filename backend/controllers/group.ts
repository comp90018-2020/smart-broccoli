import ErrorStatus from "helpers/error";
import { Group, UserGroup } from "../models";

/**
 * Create group
 * @param userId
 * @param info Group information
 */
const createGroup = async (userId: number, info: any) => {
    const group = new Group({ ownerId: userId });
    if (info.name) {
        group.name = info.name;
    }
    group.code = randomCode(6);
    return await group.save();
};

const joinGroup = async (code: string) => {
    // Find
    const group = await Group.findOne({
        where: { code },
    });
    if (!group) {
        const err = new ErrorStatus("Group not found", 404);
        throw err;
    }
};

// Charset for random generation
const CHARSET =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

/**
 * Generate random code of specified length based on charset.
 * @param length a number
 */
const randomCode = (length: number) => {
    return Array(length)
        .map(() => {
            return CHARSET[
                Math.floor(Math.random() * Math.floor(CHARSET.length))
            ];
        })
        .join("");
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
    if (group.ownerId != userId) {
        const err = new ErrorStatus("User has no access", 403);
        throw err;
    }
    return group;
};

/**
 * Regenerate and save code of specified group.
 * @param group
 */
const regenerateCode = async (group: Group) => {
    group.code = randomCode(6);
    return await group.save();
};
