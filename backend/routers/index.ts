import { Router } from "express";
import authRouter from "./auth";
import { auth } from "./middleware/auth";
import userRouter from "./user";
import groupRouter from "./group";

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
// Group
router.use("/group", auth, groupRouter);

export default router;
