import { User, Token } from "../models";
import { Op } from "sequelize";
import ErrorStatus from "../helpers/error";
import { jwtSign } from "../helpers/jwt";

// User registration
export const register = async (info: any) => {
    const { username, password, email, name } = info;
    try {
        return await User.create({ username, password, email, name });
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

// Login
export const login = async (username: string, password: string) => {
    // Find user
    const user = await User.scope().findOne({
        where: { [Op.or]: [{ username }, { email: username }] },
    });
    if (!user) {
        const err = new ErrorStatus("Incorrect username/password", 401);
        throw err;
    }

    // Verify password
    if (!(await user.verifyPassword(password))) {
        const err = new ErrorStatus("Incorrect username/password", 401);
        throw err;
    }

    // Generate and add token
    const token = await jwtSign({ id: user.id }, process.env.TOKEN_SECRET);

    return await Token.create({
        scope: "auth",
        token,
        userId: user.id,
    });
};

// Logout
export const logout = async (token: string) => {
    const tokenQuery = await Token.findOne({ where: { token } });
    tokenQuery.revoked = true;
    await tokenQuery.save();
};
