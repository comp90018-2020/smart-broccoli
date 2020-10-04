import { Op } from "sequelize";
import ErrorStatus from "../helpers/error";
import sequelize, { User, UserGroup, Picture } from "../models";
import { deletePicture, insertPicture } from "./picture";

/**
 * Get profile of current user.
 * @param userId
 */
export const getProfile = async (userId: number) => {
    return await User.findByPk(userId);
};

/**
 * Update user profile information.
 * @param userId
 * @param info Info to update
 */
export const updateProfile = async (userId: number, info: any) => {
    // Find user and update relevant fields
    const user = await User.findByPk(userId);
    if (info.email) {
        user.email = info.email;
    }
    if (info.password) {
        user.password = info.password;
    }
    if (info.name) {
        user.name = info.name;
    }

    try {
        return await user.save();
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
    }
};

/**
 * Update profile picture.
 * @param userId
 * @param file File attributes
 */
export const updateProfilePicture = async (userId: number, file: any) => {
    const user = await User.findByPk(userId, {
        attributes: ["id", "pictureId"],
    });

    const transaction = await sequelize.transaction();

    try {
        // Delete the old picture
        if (user.pictureId) {
            await deletePicture(user.pictureId, transaction);
        }
        // Insert the new picture
        const picture = await insertPicture(transaction, file);
        // Set user picture
        user.pictureId = picture.id;
        await user.save({ transaction });

        await transaction.commit();
    } catch (err) {
        await transaction.rollback();
        throw err;
    }
};

/**
 * Get profile picture.
 * Authorization is handled by caller.
 * @param pictureId ID of picture
 */
export const getProfilePicture = async (userId: number) => {
    const user = await User.findByPk(userId, { attributes: ["pictureId"] });
    const picture = await user.getPicture();
    if (!picture) {
        throw new ErrorStatus("Picture not found", 404);
    }
    return picture;
};

/**
 * Delete user's profile picture.
 * Authorization handled by caller.
 * @param pictureId ID of picture
 */
export const deleteProfilePicture = async (userId: number) => {
    const user = await User.findByPk(userId, { attributes: ["pictureId"] });
    return await deletePicture(user.pictureId);
};

/**
 * Can current user access target user's profile?
 * @param currentUserId ID of current user
 * @param userId ID of target user
 */
const canAccessProfile = async (currentUserId: number, userId: number) => {
    // TODO: fix
    // Find common groups
    const userGroups = await UserGroup.findAll({ where: { userId } });
    const sharedGroups = await UserGroup.findAll({
        where: {
            userId: currentUserId,
            [Op.or]: userGroups.map((userGroups) => {
                return { groupId: userGroups.groupId };
            }),
        },
    });
    return sharedGroups.length > 0;
};

/**
 * Get profile of user.
 * @param currentUserId ID of current user
 * @param userId ID of target user
 */
export const getUserProfile = async (currentUserId: number, userId: number) => {
    if (await canAccessProfile(currentUserId, userId)) {
        return await User.findByPk(userId, {
            attributes: ["id", "name", "updatedAt"],
        });
    }
    throw new ErrorStatus("Cannot access resource", 403);
};

/**
 * Get profile picture of other users.
 * @param currentUserId ID of current user
 * @param userId ID of target user
 */
export const getUserProfilePicture = async (
    currentUserId: number,
    userId: number
) => {
    if (await canAccessProfile(currentUserId, userId)) {
        // @ts-ignore Model problems
        const user = await User.findByPk(userId, { include: [Picture] });
        if (!user.Picture) {
            throw new ErrorStatus("Profile picture not found", 404);
        }
        return user.Picture;
    }
    throw new ErrorStatus("Cannot access resource", 403);
};
