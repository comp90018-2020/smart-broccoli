import { User, Token } from "../models";
import ErrorStatus from "../helpers/error";
import { jwtSign } from "../helpers/jwt";

// Creator registration
export const register = async (info: any) => {
    const { password, email, name } = info;
    try {
        return await User.create({ password, email, name, role: "creator" });
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

// Join
export const join = async () => {
    // Create user
    const user = await User.create({ role: "user" });

    // Generate and add token
    const token = await jwtSign({ id: user.id }, process.env.TOKEN_SECRET);
    return await Token.create({
        scope: "auth",
        token,
        userId: user.id,
    });
};

// Login
export const login = async (email: string, password: string) => {
    // Find user
    const user = await User.scope().findOne({
        where: { email },
    });
    if (!user) {
        const err = new ErrorStatus("Incorrect email/password", 403);
        throw err;
    }

    // Verify password
    if (!(await user.verifyPassword(password))) {
        const err = new ErrorStatus("Incorrect email/password", 403);
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
