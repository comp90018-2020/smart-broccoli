import { Request, Response, NextFunction, Router } from "express";
import {
    accountDataGen
} from "../dataGenForDemo/demo_data_gen";

const router = Router();

router.post(
    "/demoDataGen",
    [],
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const user = await accountDataGen()
            res.status(201);
            return res.json("OK");
        } catch (err) {
            return next(err);
        }
    }
)


export default router;
