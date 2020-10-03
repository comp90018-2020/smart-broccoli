import { Request, Response, NextFunction, Router } from "express";
import { body } from "express-validator";
import { auth } from "./middleware/auth";
import validate from "./middleware/validate";
import {
    join,
    login,
    logout,
    promoteParticipant,
    register,
} from "../controllers/auth";

const router = Router();

/**
 * @swagger
 *
 * tags:
 *   - name: Authentication
 *     description: Authentication-related routes
 *
 * components:
 *   schemas:
 *     NewUser:
 *       type: object
 *       required:
 *         - password
 *         - email
 *         - name
 *       properties:
 *         password:
 *           type: string
 *         email:
 *           type: string
 *         name:
 *           type: string
 *       example:
 *         password: foobarbaz
 *         email: foo@foo.foo
 *         name: Foo Bar
 *     User:
 *       allOf:
 *         - $ref: '#/components/schemas/NewUser'
 *         - type: object
 *           properties:
 *             id:
 *               type: integer
 *               format: int64
 *             role:
 *               type: string
 *         - example:
 *             id: 1
 *             password: foobarbaz
 *             email: foo@foo.foo
 *             name: Foo Bar
 *             role: user
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register creator account
 *     security: []
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/NewUser'
 *     responses:
 *       '201':
 *         description: User
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 */
router.post(
    "/register",
    [
        body("email").isEmail().normalizeEmail(),
        body("password").isLength({ min: 8 }),
        body("name").notEmpty().trim(),
    ],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const user = await register(req.body);
            const userJSON: any = user.toJSON();
            delete userJSON["password"];
            res.status(201);
            return res.json(userJSON);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /auth/join:
 *   post:
 *     summary: Join as user
 *     security: []
 *     tags:
 *       - Authentication
 *     responses:
 *       '200':
 *         description: user
 *         content:
 *           application/json:
 *             schema:
 *               properties:
 *                 token:
 *                   type: string
 */
router.post(
    "/join",
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const token = await join();
            return res.json({ token: token.token });
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /auth/promote:
 *   post:
 *     summary: Promote participant to user
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/NewUser'
 *     responses:
 *       '200':
 *         description: User
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 */
router.post(
    "/promote",
    [
        body("email").isEmail().normalizeEmail(),
        body("password").isLength({ min: 8 }),
        body("name").notEmpty().trim(),
    ],
    validate,
    auth,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const user = await promoteParticipant(req.user.id, req.body);
            const userJSON: any = user.toJSON();
            delete userJSON["password"];
            return res.json(userJSON);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login creator account
 *     security: []
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *             required:
 *               - email
 *               - password
 *     responses:
 *       '200':
 *         description: user
 *         content:
 *           application/json:
 *             schema:
 *               properties:
 *                 token:
 *                   type: string
 */
router.post(
    "/login",
    [
        body("email").isEmail().normalizeEmail(),
        body("password").isLength({ min: 8 }),
    ],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { email, password } = req.body;
            const token = await login(email, password);
            return res.json({ token: token.token });
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /auth/session:
 *   get:
 *     summary: Validate session
 *     tags:
 *       - Authentication
 *     responses:
 *       '200':
 *         description: OK
 */
router.get("/session", auth, (req: Request, res) => {
    return res.sendStatus(200);
});

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Logout (i.e. revoke token)
 *     tags:
 *       - Authentication
 *     responses:
 *       '200':
 *         description: OK
 */
router.post(
    "/logout",
    auth,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await logout(req.token);
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

export default router;
