import { Router, Request, Response, NextFunction } from "express";
import { body, param } from "express-validator";
import CustomStorage, { profileImageProcessor } from "../helpers/upload";
import multer, { MulterError } from "multer";
import {
    getProfilePicture,
    updateProfile,
    updateProfilePicture,
    getUserProfile,
    getUserProfilePicture,
} from "../controllers/user";
import validate from "./middleware/validate";
import fs from "fs";

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
 *     summary: Update profile user information
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
 *       '200':
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
            const userJSON: any = user.toJSON();
            delete userJSON["password"];
            return res.json(userJSON);
        } catch (err) {
            return next(err);
        }
    }
);

// Multer options
const upload = multer({
    storage: new CustomStorage({
        directorySuffix: "profile",
        imageProcessor: profileImageProcessor,
    }),
    limits: {
        files: 1,
        fileSize: 10 * 1024 * 1024, // 10MB
    },
});

/**
 * @swagger
 * /user/profile/picture:
 *   put:
 *     summary: Update user profile picture
 *     tags:
 *       - User
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               avatar:
 *                 type: string
 *                 format: binary
 *     responses:
 *       '200':
 *         description: OK
 */
router.put(
    "/profile/picture",
    (req: Request, res: Response, next: NextFunction) => {
        const avatarUpload = upload.single("avatar");

        // @ts-ignore
        avatarUpload(req, res, (err: MulterError) => {
            if (err instanceof multer.MulterError) {
                res.status(400);
                return next(err);
            }
            if (err) {
                return next(err);
            }
            return next();
        });
    },
    async (req: Request, res: Response, next: NextFunction) => {
        // Save picture information to DB
        try {
            if (!req.file) {
                const err = new Error("File not received");
                res.status(400);
                return next(err);
            }
            await updateProfilePicture(req.user.id, req.file);
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /user/profile/picture:
 *   get:
 *     summary: Get user profile picture
 *     tags:
 *       - User
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           image/png:
 *             schema:
 *               type: string
 *               format: binary
 */
router.get("/profile/picture", async (req: Request, res, next) => {
    try {
        // Get picture
        const picture = await getProfilePicture(req.user.pictureId);

        // Set content header
        res.setHeader("Content-Type", "image/png");
        // Read and serve
        const file = fs.readFileSync(`${picture.destination}.thumb`);
        res.end(file, "binary");
    } catch (err) {
        return next(err);
    }
});

/**
 * @swagger
 * /user/profile:
 *   get:
 *     summary: Get user profile
 *     tags:
 *       - User
 *     responses:
 *       '200':
 *         description: user
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 */
router.get("/profile", (req: Request, res) => {
    return res.json(req.user);
});

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
                Number(req.params.userId)
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
                Number(req.params.userId)
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
