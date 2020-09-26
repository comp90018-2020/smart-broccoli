import * as AuthController from "../controllers/auth";
import * as GroupController from "../controllers/group";

// Register as user
const register = async (info: any) => {
    const user = await AuthController.register(info);
    return user;
};

// Login as user
const registerAndLogin = async (info: any) => {
    await register(info);
    const res = await AuthController.login(info.email, info.password);
    return { id: res.userId, token: res.token };
};

// Join
const join = async () => {
    await join();
    const token = await AuthController.join();
    return token.token;
};

// Create group
const createGroup = async (userId: number, name: string) => {
    return await GroupController.createGroup(userId, name);
};

export { register, registerAndLogin, join, createGroup };
