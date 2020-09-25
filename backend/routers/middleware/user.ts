import { NextFunction, Request, Response } from "express";
import ErrorStatus from "../../helpers/error";

/**
 * Checks whether user has user role.
 */
export const assertUserRole = async (
    req: Request,
    res: Response,
    next: NextFunction
) => {
    if (!req.user) {
        const err = new Error("Role checking failure");
        return next(err);
    }

    if (req.user.role !== "user") {
        const err = new ErrorStatus("Route requires user role", 403);
        return next(err);
    }

    return next();
};
