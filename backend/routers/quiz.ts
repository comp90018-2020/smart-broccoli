import { Request, Response, NextFunction, Router } from "express";
import ErrorStatus from "../helpers/error";
import {
    createQuiz,
    deleteQuiz,
    updateQuiz,
    getQuiz,
    getAllQuiz,
    getQuizAndRole,
} from "../controllers/quiz";
import {
    updateQuestionPicture,
    getQuestionPicture,
} from "../controllers/question";
import { param, body } from "express-validator";
import validate from "./middleware/validate";
import { Quiz } from "models";
import multer from "multer";
import fs from "fs";
import CustomStorage, { questionPictureProcessor } from "../helpers/upload";

/**
 * @swagger
 *
 * tags:
 *   - name: Quiz
 *     description: Quiz routes
 * components:
 *   schemas:
 *     NewQuiz:
 *       type: object
 *       required:
 *         - title
 *         - questions
 *         - type
 *         - groupId
 *       properties:
 *         title:
 *           type: string
 *         description:
 *           type: string
 *         timeLimit:
 *           type: int64
 *         groupId:
 *           type: int64
 *         type:
 *           type: string
 *           enum:
 *             - live
 *             - self paced
 *         questions:
 *           type: array
 *           items:
 *             type: object
 *             $ref: '#/components/schemas/NewQuestion'
 *     Quiz:
 *       allOf:
 *         - $ref: '#/components/schemas/NewQuiz'
 *         - type: object
 *           required:
 *             - id
 *           properties:
 *             id:
 *               type: integer
 *               format: int64
 *             questions:
 *               type: array
 *               items:
 *                 type: object
 *                 $ref: '#/components/schemas/Question'
 *     NewQuestion:
 *       type: object
 *       required:
 *         - type
 *       properties:
 *         type:
 *           type: string
 *           enum: [truefalse, choice]
 *         text:
 *           type: string
 *         timeLimit:
 *           type: number
 *         tf:
 *           type: boolean
 *         options:
 *           type: array
 *           items:
 *             type: object
 *             required:
 *                - text
 *                - correct
 *             properties:
 *               correct:
 *                 type: boolean
 *               text:
 *                 type: string
 *     Question:
 *       allOf:
 *         - $ref: '#/components/schemas/NewQuestion'
 *         - type: object
 *           properties:
 *             id:
 *               type: integer
 *               format: int64
 */
const router = Router();

// Extend req.user
declare module "express" {
    export interface Request {
        quiz?: Quiz;
    }
}

// Check whether user is creator of quiz
export const checkQuizMembership = (intendedRole: string) => {
    return async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { quiz, role } = await getQuizAndRole(
                req.user.id,
                Number(req.params.quizId)
            );
            // Owners are members, members are participants
            if (
                role === "owner" &&
                (intendedRole === "member" || intendedRole === "participant")
            ) {
                return next();
            }
            if (role === "member" && intendedRole === "participant") {
                return next();
            }
            // No access
            if (role != intendedRole) {
                const err = new ErrorStatus("No access to quiz resource", 403);
                throw err;
            }
            req.quiz = quiz;
            return next();
        } catch (err) {
            return next(err);
        }
    };
};

/**
 * @swagger
 *
 * /quiz:
 *   post:
 *     summary: Create quiz
 *     tags:
 *       - Quiz
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/NewQuiz'
 *     responses:
 *       '200':
 *         description: Created Quiz
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Quiz'
 */
router.post(
    "/",
    [
        body("description").optional().isString(),
        body("title").isString(),
        body("timeLimit").optional().isInt(),
        body("groupId").isInt(),
        body("type").isIn(["live", "self paced"]),
        body("questions.*.tf").optional({ nullable: true }).isBoolean(),
        body("questions.*.type").optional().isIn(["truefalse", "choice"]),
        body("questions.*.options").optional({ nullable: true }).isArray(),
        body("questions.*.text").optional({ nullable: true }).isString(),
    ],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const quiz = await createQuiz(req.user.id, req.body);
            res.status(201);
            return res.json(quiz);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 *
 * /quiz:
 *   get:
 *     summary: Get quizzes accessible by user
 *     tags:
 *       - Quiz
 *     parameters:
 *       - in: query
 *         name: managed
 *         schema:
 *           type: boolean
 *           default: false
 *         description: Managed groups or as member/participant
 *     responses:
 *       '200':
 *         description: List of quizzes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 $ref: '#/components/schemas/Quiz'
 */
router.get("/", async (req: Request, res: Response, next: NextFunction) => {
    try {
        return res.json(await getAllQuiz(req.user, req.query));
    } catch (err) {
        return next(err);
    }
});

/**
 * @swagger
 *
 * /quiz/{quizId}:
 *   get:
 *     summary: Get quiz
 *     tags:
 *       - Quiz
 *     parameters:
 *       - in: path
 *         name: quizId
 *         schema:
 *           type: integer
 *         required: true
 *         description: Quiz ID
 *     responses:
 *       '200':
 *         description: Specified quiz
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Quiz'
 */
router.get(
    "/:quizId",
    [param("quizId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            return res.json(
                await getQuiz(req.user.id, Number(req.params.quizId))
            );
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 *
 * /quiz/{quizId}:
 *   patch:
 *     summary: Update quiz
 *     tags:
 *       - Quiz
 *     parameters:
 *       - in: path
 *         name: quizId
 *         schema:
 *           type: integer
 *         required: true
 *         description: Quiz ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *     responses:
 *       '200':
 *         description: Updated quiz
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Quiz'
 */
router.patch(
    "/:quizId",
    [
        param("quizId").isInt(),
        body("description").optional().isString(),
        body("title").optional().isString(),
        body("timeLimit").optional().isInt(),
        body("groupId").optional().isInt(),
        body("type").optional().isIn(["live", "self paced"]),
        body("questions.*.tf").optional({ nullable: true }).isBoolean(),
        body("questions.*.type").optional().isIn(["truefalse", "choice"]),
        body("questions.*.options").optional({ nullable: true }).isArray(),
        body("questions.*.text").optional({ nullable: true }).isString(),
    ],
    validate,
    checkQuizMembership("owner"),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const quiz = await updateQuiz(
                req.user.id,
                Number(req.params.quizId),
                req.body
            );
            return res.json(quiz);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 *
 * /quiz/{quizId}:
 *   delete:
 *     summary: Delete quiz
 *     tags:
 *       - Quiz
 *     parameters:
 *       - in: path
 *         name: quizId
 *         schema:
 *           type: integer
 *         required: true
 *         description: Quiz ID
 *     responses:
 *       '204':
 *         description: Quiz deleted
 */
router.delete(
    "/:quizId",
    [param("quizId").isInt()],
    validate,
    checkQuizMembership("owner"),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await deleteQuiz(Number(req.params.quizId));
            return res.sendStatus(204);
        } catch (err) {
            return next(err);
        }
    }
);

// Multer options
const upload = multer({
    storage: new CustomStorage({
        directorySuffix: "question",
        imageProcessor: questionPictureProcessor,
    }),
    limits: {
        files: 1,
        fileSize: 10 * 1024 * 1024, // 10MB
    },
});

/**
 * @swagger
 * /quiz/{quizId}/question/{questionId}/picture:
 *   put:
 *     summary: Update question picture
 *     tags:
 *       - Quiz
 *     parameters:
 *       - in: path
 *         name: quizId
 *         schema:
 *           type: integer
 *         required: true
 *         description: Quiz ID
 *       - in: path
 *         name: questionId
 *         schema:
 *           type: integer
 *         required: true
 *         description: Question ID
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
    "/:quizId/question/:questionId/picture",
    validate,
    checkQuizMembership("owner"),
    (req: Request, res: Response, next: NextFunction) => {
        const pictureUpload = upload.single("picture");

        // @ts-ignore
        pictureUpload(req, res, (err: MulterError) => {
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
            await updateQuestionPicture(
                Number(req.params.quizId),
                Number(req.params.questionId),
                req.file
            );
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /quiz/{quizId}/question/{questionId}/picture:
 *   get:
 *     summary: Get question picture
 *     tags:
 *       - Quiz
 *     parameters:
 *       - in: path
 *         name: quizId
 *         schema:
 *           type: integer
 *         required: true
 *         description: Quiz ID
 *       - in: path
 *         name: questionId
 *         schema:
 *           type: integer
 *         required: true
 *         description: Question ID
 *     responses:
 *       '200':
 *         description: OK
 *     requestBody:
 *       required: true
 *       content:
 *         image/png:
 *           schema:
 *             type: string
 *             format: binary
 */
router.get(
    "/:quizId/question/:questionId/picture",
    validate,
    checkQuizMembership("participant"),
    async (req: Request, res, next) => {
        try {
            const picture = await getQuestionPicture(
                Number(req.params.quizId),
                Number(req.params.questionId)
            );
            if (!picture) {
                const err = new ErrorStatus("Picture not found", 404);
                throw err;
            }

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
