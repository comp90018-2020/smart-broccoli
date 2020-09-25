import { Router, Request, Response, NextFunction } from "express";
import { body, param } from "express-validator";
import {
    createGroup,
    deleteMember,
    getGroup,
    getGroupAndVerifyRole,
    getGroups,
    joinGroup,
    leaveGroup,
    updateGroup,
} from "../controllers/group";
import { Group } from "../models";
import validate from "./middleware/validate";

const router = Router();

// Extend req.user
declare module "express" {
    export interface Request {
        group: Group;
    }
}

/**
 * Get group and verify role.
 * @param role
 */
const verifyRole = (role: string) => {
    return async (req: Request, res: Response, next: NextFunction) => {
        const group = await getGroupAndVerifyRole(
            req.user.id,
            Number(req.params.groupId),
            role
        );
        req.group = group;
    };
};

router.post(
    "/",
    [body("name").isString()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const group = await createGroup(req.user.id, req.body.name);
            res.status(201);
            return res.json(group);
        } catch (err) {
            return next(err);
        }
    }
);

router.get("/", async (req: Request, res: Response, next: NextFunction) => {
    try {
        const groups = await getGroups(req.user.id);
        return res.json(groups);
    } catch (err) {
        return next(err);
    }
});

router.get(
    "/:groupId",
    [param("groupId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const group = await getGroup(
                req.user.id,
                Number(req.params.groupId)
            );
            return res.json(group);
        } catch (err) {
            return next(err);
        }
    }
);

router.post(
    "/join",
    [body("name").isString()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await joinGroup(req.user.id, req.body.name);
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

router.patch(
    "/:groupId",
    [param("groupId").isInt(), body("name").optional().isString()],
    validate,
    verifyRole("owner"),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const group = await updateGroup(req.group, req.body.name);
            return res.json(group);
        } catch (err) {
            return next(err);
        }
    }
);

router.post(
    "/:groupId/leave",
    [param("groupId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await leaveGroup(Number(req.params.groupId), req.user.id);
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

router.post(
    "/:groupId/kick",
    [param("groupId").isInt(), body("memberId").isInt()],
    validate,
    verifyRole("owner"),
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await deleteMember(Number(req.params.groupId), req.body.memberId);
            return res.sendStatus(200);
        } catch (err) {
            return next(err);
        }
    }
);

export default router;
