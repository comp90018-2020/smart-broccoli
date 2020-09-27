import * as AuthController from "../controllers/auth";
import * as QuizController from "../controllers/quiz";

// Register as creator
import * as GroupController from "../controllers/group";

// Register as user
export const register = async (info: any) => {
    const user = await AuthController.register(info);
    return user;
};

// Login as user
export const registerAndLogin = async (info: any) => {
    await register(info);
    const res = await AuthController.login(info.email, info.password);
    return { id: res.userId, token: res.token };
};

// Join
export const join = async () => {
    await join();
    const token = await AuthController.join();
    return token.token;
};

// Create quiz
export const createQuiz = QuizController.createQuiz;

// Create group
export const createGroup = GroupController.createGroup;

// Join group
export const joinGroup = GroupController.joinGroup;
