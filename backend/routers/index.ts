import { Router } from "express";
import { auth } from "./middleware/auth";
import authRouter from "./auth";
import userRouter from "./user";
import groupRouter from "./group";
import quizRouter from "./quiz";
import sessionRouter from "./session";

const router = Router();

/**
 * @swagger
 *
 * components:
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */

// Authentication
router.use("/auth", authRouter);
// User
router.use("/user", userRouter);
// Quiz
router.use("/quiz", quizRouter);
// Group
router.use("/group", auth(), groupRouter);
// Quiz session
router.use("/session", auth(), sessionRouter);

export default router;
