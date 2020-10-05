import sequelize, { User, Token } from "../models";
import ErrorStatus from "../helpers/error";
import { jwtSign } from "../helpers/jwt";
import { createDefaultGroup } from "./group";

/**
 * User registration.
 * @param info email, name, password
 */
export const register = async (info: any) => {
    const { password, email, name } = info;
    const transaction = await sequelize.transaction();

    try {
        const user = await User.create(
            { password, email, name, role: "user" },
            { transaction }
        );
        await createDefaultGroup(user.id, transaction);
        await transaction.commit();
        return user;
    } catch (err) {
        await transaction.rollback();

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
 * Join as participant.
 */
export const join = async () => {
    // Create user
    const user = await User.create({ role: "participant" });

    // Generate and add token
    const token = await jwtSign({ id: user.id }, process.env.TOKEN_SECRET);
    return await Token.create({
        scope: "auth",
        token,
        userId: user.id,
    });
};

/**
 * Login as user.
 * @param email
 * @param password
 */
export const login = async (email: string, password: string) => {
    // Find user
    const user = await User.scope().findOne({
        where: { email, role: "user" },
        attributes: ["id", "password"],
    });
    if (!user) {
        throw new ErrorStatus("Incorrect email/password", 403);
    }

    // Verify password
    if (!(await user.verifyPassword(password))) {
        throw new ErrorStatus("Incorrect email/password", 403);
    }

    // Generate and add token
    const token = await jwtSign({ id: user.id }, process.env.TOKEN_SECRET);
    return await Token.create({
        scope: "auth",
        token,
        userId: user.id,
    });
};

/**
 * Logout: revoke token to end session.
 * @param token
 */
export const logout = async (token: string) => {
    const tokenQuery = await Token.findOne({ where: { token } });
    tokenQuery.revoked = true;
    await tokenQuery.save();
};

/**
 * Promotes a participant to a user.
 * @param info email, name, password
 */
export const promoteParticipant = async (userId: number, info: any) => {
    const user = await User.findByPk(userId);
    if (!user) {
        throw new ErrorStatus("User not found", 404);
    }
    if (user.role === "user") {
        throw new ErrorStatus("User is already promoted", 400);
    }

    user.password = info.password;
    user.role = "user";
    user.email = info.email;
    user.name = info.name;

    const transaction = await sequelize.transaction();

    try {
        await user.save({ transaction });
        await createDefaultGroup(user.id, transaction);
        await transaction.commit();
        return user;
    } catch (err) {
        await transaction.rollback();

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
