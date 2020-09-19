import { Request, Response, NextFunction, Router } from "express";
import ErrorStatus from "../helpers/error";
import { createQuiz, deleteQuiz, updateQuiz } from "../controllers/quiz";
import { param, body } from "express-validator";
import validate from "./middleware/validate";

const router = Router();

// Checks whether user is a creator
const creatorCheck = (req: Request, res: Response, next: NextFunction) => {
    if (req.user.role !== "creator") {
        const err = new ErrorStatus("Not creator, cannot create quiz", 403);
        return next(err);
    }
    return next();
};

router.post("/", async (req: Request, res: Response, next: NextFunction) => {
    try {
        const quiz = await createQuiz(req.user.id);
        res.status(201);
        return res.json(quiz);
    } catch (err) {
        return next(err);
    }
});

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
