import { Request, Response, NextFunction, Router } from "express";
import ErrorStatus from "../helpers/error";
import {
    addQuestion,
    createQuiz,
    deleteQuestion,
    deleteQuiz,
    updateQuestion,
    updateQuiz,
    getQuizCreator,
    getQuiz,
    getAllQuiz,
} from "../controllers/quiz";
import { param, body } from "express-validator";
import validate from "./middleware/validate";
import { Quiz } from "models";

/**
 * @swagger
 *
 * tags:
 *   - name: Quiz
 *     description: Quiz routes
 * components:
 *   schemas:
 *     Quiz:
 *       type: object
 *       required:
 *         - id
 *       properties:
 *         id:
 *           type: number
 *         title:
 *           type: string
 *         description:
 *           type: string
 *       example:
 *         id: 1
 *         title: Quiz title
 *         description: A description about quiz
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

// Checks whether user is a creator
export const creatorRoleCheck = (
    req: Request,
    res: Response,
    next: NextFunction
) => {
    if (req.user.role !== "creator") {
        const err = new ErrorStatus("Not creator, cannot create quiz", 403);
        return next(err);
    }
    return next();
};

// Check whether user is creator of quiz
export const isQuizCreator = async (
    req: Request,
    res: Response,
    next: NextFunction
) => {
    try {
        req.quiz = await getQuizCreator(req.user.id, Number(req.params.quizId));
        return next();
    } catch (err) {
        return next(err);
    }
};

/**
 * @swagger
 *
 * /quiz:
 *   post:
 *     description: Create quiz
 *     tags:
 *       - Quiz
 *     responses:
 *       '200':
 *         description: Created Quiz
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Quiz'
 */
router.post("/", async (req: Request, res: Response, next: NextFunction) => {
    try {
        const quiz = await createQuiz(req.user.id);
        res.status(201);
        return res.json({ ...quiz.toJSON(), questions: [] });
    } catch (err) {
        return next(err);
    }
});

/**
 * @swagger
 *
 * /quiz:
 *   get:
 *     summary: Get quiz created by user
 *     tags:
 *       - Quiz
 *     responses:
 *       '200':
 *         description: Quiz created by user
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
        return res.json(await getAllQuiz(req.user.id));
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
 *     description: Update quiz
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
 *         description: Created Quiz
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
    ],
    validate,
    isQuizCreator,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const quiz = await updateQuiz(req.quiz, req.body);
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
 *     description: Delete quiz
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
 *         description: Quiz deleted
 */
router.delete(
    "/:quizId",
    [param("quizId").isInt()],
    validate,
    isQuizCreator,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await deleteQuiz(Number(req.params.quizId));
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

// Validator for questions
const questionValidator = [
    body("timeLimit").optional().isInt(),
    body("tf").optional().isBoolean(),
    body("type").isIn(["truefalse", "choice"]),
    body("options").optional().isArray(),
    body("text").optional().isString(),
];

/**
 * @swagger
 *
 * /quiz/{quizId}/question:
 *   post:
 *     summary: Create question
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
 *             $ref: '#/components/schemas/NewQuestion'
 *     responses:
 *       '201':
 *         description: Created question
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Question'
 */
router.post(
    "/:quizId/question",
    [...questionValidator, param("quizId").isInt()],
    validate,
    isQuizCreator,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const question = await addQuestion(
                Number(req.params.quizId),
                req.body
            );
            res.status(201);
            return res.json(question);
        } catch (err) {
            return next(err);
        }
    }
);
/**
 * @swagger
 *
 * /quiz/{quizId}/question/{questionId}:
 *   put:
 *     summary: Update question
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
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/NewQuestion'
 *     responses:
 *       '200':
 *         description: Updated question
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Question'
 */
router.put(
    "/:quizId/question/:questionId",
    [
        ...questionValidator,
        param("quizId").isInt(),
        param("questionId").isInt(),
    ],
    validate,
    isQuizCreator,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const question = await updateQuestion(
                Number(req.params.quizId),
                Number(req.params.questionId),
                req.body
            );
            return res.json(question);
        } catch (err) {
            return next(err);
        }
    }
);
/**
 * @swagger
 *
 * /quiz/{quizId}/question/{questionId}:
 *   delete:
 *     summary: Delete question
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
 *         description: Question deleted
 */
router.delete(
    "/:quizId/question/:questionId",
    [param("quizId").isInt(), param("questionId").isInt()],
    validate,
    isQuizCreator,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await deleteQuestion(
                Number(req.params.quizId),
                Number(req.params.questionId)
            );
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

export default router;
