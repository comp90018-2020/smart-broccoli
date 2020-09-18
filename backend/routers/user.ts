import { Router, Request, Response, NextFunction } from "express";
import { body } from "express-validator";
import CustomStorage, { profileImageProcessor } from "../helpers/upload";
import multer, { MulterError } from "multer";
import { updateProfile, updateProfilePicture } from "../controllers/user";
import validate from "./middleware/validate";
import ErrorStatus from "../helpers/error";

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

// Multer options
const upload = multer({
    storage: new CustomStorage({
        directoryPrefix: "profile",
        imageProcessor: profileImageProcessor,
    }),
    limits: {
        files: 1,
        fileSize: 10 * 1024 * 1024, // 10MB
    },
});

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
        await updateProfilePicture(req.user.id, req.file);
        return res.sendStatus(200);
    }
);

export default router;
