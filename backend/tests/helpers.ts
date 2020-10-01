import * as AuthController from "../controllers/auth";
import * as GroupController from "../controllers/group";
import * as QuizController from "../controllers/quiz";

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

// Create group
export const createGroup = GroupController.createGroup;

// Join group
export const joinGroup = GroupController.joinGroup;

// Create quiz
export const createQuiz = async (
    userId: number,
    groupId: number,
    quiz: any
) => {
    return await QuizController.createQuiz(userId, { ...quiz, groupId });
};
