import { Request, Response, NextFunction, Router } from "express";
import ErrorStatus from "../helpers/error";
import { createQuiz, deleteQuiz, updateQuiz } from "../controllers/quiz";
import { param, body } from "express-validator";
import validate from "./middleware/validate";

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
 */
const router = Router();

// Checks whether user is a creator
const creatorCheck = (req: Request, res: Response, next: NextFunction) => {
    if (req.user.role !== "creator") {
        const err = new ErrorStatus("Not creator, cannot create quiz", 403);
        return next(err);
    }
    return next();
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
        return res.json({ ...quiz, questions: [] });
    } catch (err) {
        return next(err);
    }
});

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
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await deleteQuiz(req.user.id, Number(req.params.quizId));
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

export default router;
export { creatorCheck };
