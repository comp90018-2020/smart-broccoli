import { Router, Request, Response, NextFunction } from "express";
import { body, param } from "express-validator";
import fs from "fs";
import multer, { MulterError } from "multer";
import CustomStorage, { profileImageProcessor } from "../helpers/upload";
import validate from "./middleware/validate";
import ErrorStatus from "../helpers/error";
import {
    getProfilePicture,
    updateProfile,
    updateProfilePicture,
    deleteProfilePicture,
    getProfile,
    getUserProfilePicture,
    getUserProfile,
} from "../controllers/user";
import { auth } from "./middleware/auth";
import {
    getNotificationSettings,
    updateNotificationSettings,
    updateNotificationState,
} from "../controllers/notification";

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
    auth(),
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
    auth(),
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
                return next(new ErrorStatus("File not received", 400));
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
router.get("/profile/picture", auth(), async (req: Request, res, next) => {
    try {
        // Get picture
        const picture = await getProfilePicture(req.user.id);

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
 * /user/profile/picture:
 *   delete:
 *     summary: Delete profile picture
 *     tags:
 *       - User
 *     responses:
 *       '204':
 *         description: No content
 */
router.delete("/profile/picture", auth(), async (req: Request, res, next) => {
    try {
        await deleteProfilePicture(req.user.id);
        return res.sendStatus(204);
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
router.get(
    "/profile",
    auth(),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            return res.json(await getProfile(req.user.id));
        } catch (err) {
            return next(err);
        }
    }
);

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
    auth({ sessionAuth: true }),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const user = await getUserProfile(
                req.user ? req.user.id : undefined,
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
    auth({ sessionAuth: true }),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const picture = await getUserProfilePicture(
                req.user ? req.user.id : undefined,
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

/**
 * @swagger
 * /user/state:
 *   put:
 *     summary: Update user availability/state
 *     tags:
 *       - User
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             properties:
 *               free:
 *                 type: boolean
 *     responses:
 *       '200':
 *         description: OK
 */
router.put(
    "/state",
    [body("free").isBoolean(), body("calendarFree").isBoolean()],
    validate,
    auth(),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await updateNotificationState(req.user.id, req.body);
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * components:
 *   schemas:
 *     Location:
 *       type: object
 *       required:
 *         - lat
 *         - lon
 *       properties:
 *         lat:
 *           type: number
 *         lon:
 *           type: number
 *     NotificationSettings:
 *       type: object
 *       required:
 *         - onTheMove
 *         - onCommute
 *         - calendar
 *         - days
 *         - timeZone
 *         - notificationWindow
 *         - maxNotificationsPerDay
 *       properties:
 *         onTheMove:
 *           type: boolean
 *         onCommute:
 *           type: boolean
 *         calendar:
 *           type: boolean
 *         days:
 *           type: array
 *           minItems: 7
 *           maxItems: 7
 *           items:
 *             type: boolean
 *         timezone:
 *           type: string
 *         ssid:
 *           type: string
 *         location:
 *           type: object
 *           $ref: '#/components/schemas/Location'
 *         radius:
 *           type: integer
 *         notificationWindow:
 *           type: integer
 *         maxNotificationsPerDay:
 *           type: integer
 */

/**
 * @swagger
 * /user/notification:
 *   put:
 *     summary: Update user notification settings
 *     tags:
 *       - User
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/NotificationSettings'
 *     responses:
 *       '200':
 *         description: OK
 */
router.put(
    "/notification",
    [
        body("onTheMove").isBoolean(),
        body("onCommute").isBoolean(),
        body("calendarLive").isBoolean(),
        body("calendarSelfPaced").isBoolean(),
        body("days").isArray({ min: 7, max: 7 }),
        body("timezone").optional().isString(),
        body("ssid").optional().isString(),
        body("location.lat").optional().isString(),
        body("location.lon").optional().isString(),
        body("radius").optional().isInt({ min: 0 }),
        body("notificationWindow").isInt({ min: 0 }),
        body("maxNotificationsPerDay").isInt({ min: 0 }),
    ],
    validate,
    auth(),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const saved = await updateNotificationSettings(
                req.user.id,
                req.body
            );
            return res.json(saved);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /user/notification:
 *   get:
 *     summary: Get user notification settings
 *     tags:
 *       - User
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/NotificationSettings'
 */
router.get(
    "/notification",
    auth(),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            return res.json(await getNotificationSettings(req.user.id));
        } catch (err) {
            return next(err);
        }
    }
);

export default router;
