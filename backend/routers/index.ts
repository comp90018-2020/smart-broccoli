import { Router } from "express";
import authRouter from "./auth";
import { auth } from "./middleware/auth";
import userRouter from "./user";

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

export default router;
