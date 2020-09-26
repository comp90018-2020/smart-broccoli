import { Router } from "express";
import { auth } from "./middleware/auth";
import authRouter from "./auth";
import userRouter from "./user";
import groupRouter from "./group";
import quizRouter from './quiz';

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
router.use("/user", auth, userRouter);
// Quiz
router.use("/quiz", auth, quizRouter);
// Group
router.use("/group", auth, groupRouter);

export default router;
