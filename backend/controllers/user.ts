import ErrorStatus from "../helpers/error";
import { User } from "../models";

// Update user profile info
const updateProfile = async (id: number, info: any) => {
    // Find user and update relevant fields
    const user = await User.findByPk(id);
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

export { updateProfile };
