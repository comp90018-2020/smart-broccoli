import { NextFunction, Request, Response, Router } from "express";
import { body } from "express-validator";
import validate from "./middleware/validate";
import {
    createSession,
    getUserSession,
    joinSession,
} from "../controllers/session";

/**
 * @swagger
 *
 * tags:
 *   - name: Session
 *     description: Quiz Session routes (excludes gameplay)
 * components:
 *   schemas:
 *     NewQuizSession:
 *       type: object
 *       required:
 *         - quizId
 *         - isGroup
 *       properties:
 *         quizId:
 *           type: number
 *         isGroup:
 *           type: boolean
 *         subscribeGroup:
 *           type: boolean
 *     QuizSession:
 *       allOf:
 *         - $ref: '#/components/schemas/NewQuizSession'
 *         - type: object
 *           properties:
 *             id:
 *               type: integer
 *               format: int64
 *             code:
 *               type: string
 *             state:
 *               type: string
 *               enum: [waiting, active, complete]
 *     SessionComplete:
 *       type: object
 *       properties:
 *         token:
 *           type: string
 *         session:
 *           $ref: '#/components/schemas/QuizSession'
 */
const router = Router();

/**
 * @swagger
 *
 * /session:
 *   post:
 *     summary: Create session
 *     tags:
 *       - Session
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/NewQuizSession'
 *     responses:
 *       '200':
 *         description: Session and token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SessionComplete'
 */
router.post(
    "/",
    [
        body("quizId").isInt(),
        body("isGroup").isBoolean(),
        body("subscribeGroup").optional().isBoolean(),
    ],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const session = await createSession(req.user.id, req.body);
            return res.json(session);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 *
 * /session:
 *   get:
 *     summary: Get current user session
 *     tags:
 *       - Session
 *     responses:
 *       '204':
 *         description: No current session
 *       '200':
 *         description: Session and token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SessionComplete'
 */
router.get("/", async (req: Request, res: Response, next: NextFunction) => {
    try {
        const session = await getUserSession(req.user.id);
        if (!session) {
            return res.sendStatus(204);
        } else {
            return res.json(session);
        }
    } catch (err) {
        return next(err);
    }
});

/**
 * @swagger
 *
 * /session/join:
 *   post:
 *     summary: Join session by code
 *     tags:
 *       - Session
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             properties:
 *               code:
 *                 type: string
 *     responses:
 *       '200':
 *         description: Session and token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SessionComplete'
 */
router.post(
    "/join",
    [body("code").isString().isLength({ min: 6, max: 6 })],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const session = await joinSession(req.user.id, req.body.code);
            return res.json(session);
        } catch (err) {
            return next(err);
        }
    }
);
export default router;
