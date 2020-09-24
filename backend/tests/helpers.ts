import * as AuthController from "../controllers/auth";

// Register as user
const register = async (info: any) => {
    const user = await AuthController.register(info);
    return user;
};

// Login as user
const registerAndLogin = async (info: any) => {
    await register(info);
    const res = await AuthController.login(info.email, info.password);
    return res.token;
};

// Join
const join = async () => {
    await join();
    const token = await AuthController.join();
    return token.token;
};

export { register, registerAndLogin, join };
