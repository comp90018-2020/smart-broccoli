import { Router, Request, Response, NextFunction } from "express";
import { body, param } from "express-validator";
import { assertUserRole } from "./middleware/user";
import validate from "./middleware/validate";
import {
    createGroup,
    deleteGroup,
    deleteMember,
    getGroup,
    getGroupMembers,
    getGroupQuizzes,
    getGroups,
    joinGroup,
    leaveGroup,
    regenerateCode,
    updateGroup,
} from "../controllers/group";

/**
 * @swagger
 *
 * tags:
 *   - name: Group
 *     description: Group routes
 * components:
 *   schemas:
 *     GroupBrief:
 *       type: object
 *       required:
 *         - name
 *         - id
 *       properties:
 *         id:
 *           type: number
 *         name:
 *           type: string
 *         defaultGroup:
 *           type: boolean
 *         code:
 *           type: string
 *     UserBrief:
 *       type: object
 *       properties:
 *         id:
 *           type: number
 *         name:
 *           type: string
 *         role:
 *           type: string
 *           enum: [member, owner]
 */
const router = Router();

/**
 * @swagger
 * /group:
 *   post:
 *     summary: Create group
 *     tags:
 *       - Group
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             properties:
 *               name:
 *                 type: string
 *             required:
 *               - name
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/GroupBrief'
 */
router.post(
    "/",
    [body("name").isString()],
    validate,
    assertUserRole,
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

/**
 * @swagger
 * /group/{groupId}:
 *   patch:
 *     summary: Update group
 *     tags:
 *       - Group
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             properties:
 *               name:
 *                 type: string
 *             required:
 *               - name
 *     parameters:
 *       - in: path
 *         name: groupId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/GroupBrief'
 */
router.patch(
    "/:groupId",
    [param("groupId").isInt(), body("name").optional().isString()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const group = await updateGroup(
                req.user.id,
                Number(req.params.groupId),
                req.body.name
            );
            return res.json(group);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /group:
 *   get:
 *     summary: Get all groups
 *     tags:
 *       - Group
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 allOf:
 *                   - $ref: '#/components/schemas/GroupBrief'
 *                   - type: object
 *                     properties:
 *                       role:
 *                         type: string
 *                         enum: [owner, member]
 */
router.get("/", async (req: Request, res: Response, next: NextFunction) => {
    try {
        const groups = await getGroups(req.user);
        return res.json(groups);
    } catch (err) {
        return next(err);
    }
});

/**
 * @swagger
 * /group/{groupId}:
 *   get:
 *     summary: Get group by ID
 *     tags:
 *       - Group
 *     parameters:
 *       - in: path
 *         name: groupId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/GroupBrief'
 */
router.get(
    "/:groupId",
    [param("groupId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const group = await getGroup(
                req.user,
                Number(req.params.groupId)
            );
            return res.json(group);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /group/{groupId}/quiz:
 *   get:
 *     summary: Get quizzes of group
 *     tags:
 *       - Group
 *     parameters:
 *       - in: path
 *         name: groupId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 $ref: '#/components/schemas/Quiz'
 */
router.get(
    "/:groupId/quiz",
    [param("groupId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const quizzes = await getGroupQuizzes(
                req.user.id,
                Number(req.params.groupId)
            );
            return res.json(quizzes);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /group/join:
 *   post:
 *     summary: Join group by name or code
 *     tags:
 *       - Group
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             properties:
 *               name:
 *                 type: string
 *               code:
 *                 type: string
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/GroupBrief'
 *               properties:
 *                 role:
 *                   type: string
 *                   enum: [member, owner]
 */
router.post(
    "/join",
    [body("name").optional().isString(), body("code").optional().isString()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const group = await joinGroup(req.user.id, {
                name: req.body.name,
                code: req.body.code,
            });
            return res.json(group);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /group/{groupId}/code:
 *   post:
 *     summary: Regenerate code
 *     tags:
 *       - Group
 *     parameters:
 *       - in: path
 *         name: groupId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/GroupBrief'
 */
router.post(
    "/:groupId/code",
    [param("groupId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const group = await regenerateCode(
                req.user.id,
                Number(req.params.groupId)
            );
            return res.json(group);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /group/{groupId}/leave:
 *   post:
 *     summary: Leave group
 *     tags:
 *       - Group
 *     parameters:
 *       - in: path
 *         name: groupId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '204':
 *         description: No Content
 */
router.post(
    "/:groupId/leave",
    [param("groupId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await leaveGroup(Number(req.params.groupId), req.user.id);
            return res.sendStatus(204);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /group/{groupId}/member:
 *   get:
 *     summary: Get group members
 *     tags:
 *       - Group
 *     parameters:
 *       - in: path
 *         name: groupId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '200':
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 $ref: '#/components/schemas/UserBrief'
 */
router.get(
    "/:groupId/member",
    [param("groupId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            const members = await getGroupMembers(
                req.user.id,
                Number(req.params.groupId)
            );
            return res.json(members);
        } catch (err) {
            throw next(err);
        }
    }
);

/**
 * @swagger
 * /group/{groupId}/member/kick:
 *   post:
 *     summary: Kick member from group
 *     tags:
 *       - Group
 *     parameters:
 *       - in: path
 *         name: groupId
 *         schema:
 *           type: integer
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             properties:
 *               memberId:
 *                 type: string
 *             required:
 *               - memberId
 *     responses:
 *       '204':
 *         description: No Content
 */
router.post(
    "/:groupId/member/kick",
    [param("groupId").isInt(), body("memberId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await deleteMember(
                req.user.id,
                Number(req.params.groupId),
                req.body.memberId
            );
            return res.sendStatus(204);
        } catch (err) {
            return next(err);
        }
    }
);

/**
 * @swagger
 * /group/{groupId}:
 *   delete:
 *     summary: Delete group
 *     tags:
 *       - Group
 *     parameters:
 *       - in: path
 *         name: groupId
 *         schema:
 *           type: integer
 *         required: true
 *     responses:
 *       '204':
 *         description: Deleted
 */
router.delete(
    "/:groupId",
    [param("groupId").isInt()],
    validate,
    async (req: Request, res: Response, next: NextFunction) => {
        try {
            await deleteGroup(req.user.id, Number(req.params.groupId));
            return res.sendStatus(204);
        } catch (err) {
            return next(err);
        }
    }
);

export default router;
