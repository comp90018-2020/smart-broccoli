import { Request, Response, NextFunction, Router } from "express";
import ErrorStatus from "../helpers/error";
import { createQuiz } from "../controllers/quiz";

const router = Router();

const creatorCheck = (req: Request, res: Response, next: NextFunction) => {
    if (req.user.role !== "creator") {
        const err = new ErrorStatus("Not creator, cannot create quiz", 403);
        return next(err);
    }
    return next();
};

router.post("/", async (req: Request, res: Response, next: NextFunction) => {
    try {
        await createQuiz(req.user.id);
        return res.sendStatus(201);
    } catch (err) {
        return next(err);
    }
});

export default router;
export { creatorCheck };
