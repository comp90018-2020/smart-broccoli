import { createGroup } from "controllers/group";
import { Router, Request, Response, NextFunction } from "express";

const router = Router();

router.post("/", async (req: Request, res: Response, next: NextFunction) => {
    try {
        await createGroup(req.user.id, req.body.name);
    } catch (err) {
        return next(err);
    }
});

export default router;
