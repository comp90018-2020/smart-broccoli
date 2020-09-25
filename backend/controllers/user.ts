import ErrorStatus from "../helpers/error";
import { User } from "../models";
import { deletePicture, getPictureById, insertPicture } from "./picture";

/**
 * Update user profile information.
 * @param userId
 * @param info Info to update
 */
const updateProfile = async (userId: number, info: any) => {
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
const updateProfilePicture = async (userId: number, file: any) => {
    const user = await User.findByPk(userId);

    // Delete the old picture
    if (user.pictureId) {
        await deletePicture(user.pictureId);
    }
    // Insert the new picture
    const picture = await insertPicture(file);
    // Set user picture
    user.pictureId = picture.id;
    return await user.save();
};

/**
 * Get profile picture.
 * Authorization is handled by caller.
 * @param pictureId ID of picture
 */
const getProfilePicture = async (pictureId: number) => {
    return await getPictureById(pictureId);
};

export { updateProfile, updateProfilePicture, getProfilePicture };
