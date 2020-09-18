import { Router, Request, Response, NextFunction } from "express";
import { body, param } from "express-validator";
import { updateProfile } from "../controllers/user";
import validate from "./middleware/validate";

/**
 * @swagger
 *
 * tags:
 *   - name: User
 *     description: User routes
 */
const router = Router();

/**
 * @swagger
 * /user/profile:
 *   patch:
 *     description: Update user information, fields optionally required
 *     tags:
 *       - User
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
 *               name:
 *                 type: string
 *     responses:
 *       '201':
 *         description: User
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 */
router.patch(
    "/profile",
    [
        body("email").optional().isEmail().normalizeEmail(),
        body("name").optional().notEmpty().trim(),
        body("password").optional().isLength({ min: 8 }),
    ],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const user = await updateProfile(req.user.id, req.body);
            return res.json(user);
        } catch (err) {
            return next(err);
        }
    }
);

router.put("/profile/picture");

export default router;
