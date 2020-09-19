import * as AuthController from "../controllers/auth";
import * as QuizController from "../controllers/quiz";

// Register as creator
export const register = async (info: any) => {
    const user = await AuthController.register(info);
    return user;
};

// Login as creator
export const registerAndLogin = async (info: any) => {
    const user = await register(info);
    const res = await AuthController.login(info.email, info.password);
    return { token: res.token, id: user.id };
};

// Join
export const join = async () => {
    await join();
    const token = await AuthController.join();
    return token.token;
};

// Create quiz
export const createQuiz = async (userId: number) => {
    const quiz = await QuizController.createQuiz(userId);
    return quiz;
};
