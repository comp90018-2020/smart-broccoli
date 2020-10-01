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
        return next(new Error("Role checking failure"));
    }

    if (req.user.role !== "user") {
        return next(new ErrorStatus("Route requires user role", 403));
    }

    return next();
};
