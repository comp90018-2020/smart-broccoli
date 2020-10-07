import { Router, Request, Response, NextFunction } from "express";
import { param } from "express-validator";
import fs from "fs";
import validate from "./middleware/validate";
import { getUserProfile, getUserProfilePicture } from "../controllers/user";

// Router for getting other users' profiles
const router = Router();

/**
 * @swagger
 * /user/{userId}/profile:
 *   get:
 *     summary: Get user profile
 *     description: Authorization is by group/quiz session membership
 *     tags:
 *       - User
 *     parameters:
 *       - in: path
 *         name: userId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '200':
 *         description: user
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 */
router.get(
    "/:userId/profile",
    [param("userId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const user = await getUserProfile(
                req.user.id,
                Number(req.params.userId),
                req.token
            );
            return res.json(user);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /user/{userId}/profile/picture:
 *   get:
 *     summary: Get user profile picture
 *     description: Authorization is by group/quiz session membership
 *     tags:
 *       - User
 *     parameters:
 *       - in: path
 *         name: userId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           image/png:
 *             schema:
 *               type: string
 *               format: binary
 */
router.get(
    "/:userId/profile/picture",
    [param("userId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const picture = await getUserProfilePicture(
                req.user.id,
                Number(req.params.userId),
                req.token
            );
            // Set content header
            res.setHeader("Content-Type", "image/png");

            // Read and serve
            const file = fs.readFileSync(`${picture.destination}.thumb`);
            res.end(file, "binary");
        } catch (err) {
            return next(err);
        }
    }
);

export default router;
