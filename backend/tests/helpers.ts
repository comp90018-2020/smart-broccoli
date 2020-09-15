import * as AuthController from "../controllers/auth";

// Register user
const register = async (info: any) => {
    const user = await AuthController.register(info);
    return user;
};

// Login as user
const registerAndLogin = async (info: any) => {
    await register(info);
    const res = await AuthController.login(info.username, info.password);
    return res.token;
};

export { register, registerAndLogin };
