import { login, logout, register } from "../controllers/auth";
import { Request, Response, NextFunction, Router } from "express";
import { body } from "express-validator";
import { auth } from "./middleware/auth";
import validate from "./middleware/validate";
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
 *         - example:
 *             id: 1
 *             password: foobarbaz
 *             email: foo@foo.foo
 *             name: Foo Bar
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     description: Create new user
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
        body("email").isEmail().normalizeEmail().trim(),
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
 * /auth/login:
 *   post:
 *     description: User login
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
    [body("email").notEmpty().trim(), body("password").isLength({ min: 8 })],
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
 *     description: Validate session & Get user info
 *     tags:
 *       - Authentication
 *     responses:
 *       '200':
 *         description: user
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 */
router.get("/session", auth, (req: Request, res) => {
    return res.json(req.user);
});

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     description: Logout (i.e. revoke token)
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
