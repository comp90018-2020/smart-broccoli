import { NextFunction, Request, Response } from "express";
import ErrorStatus from "../../helpers/error";
import Token from "../../models/token";
import { User } from "../../models";
import { jwtVerify } from "../../helpers/jwt";

// Extend req.user
declare module "express" {
    export interface Request {
        user: User;
        token: string;
    }
}

// JWT token-based authentication
export const auth = (
    opts: { sessionAuth: boolean } = { sessionAuth: false }
) => {
    return async (req: Request, res: Response, next: NextFunction) => {
        // Examine header
        const auth_header = req.header("authorization");
        if (
            !auth_header ||
            !auth_header.toLocaleLowerCase().includes("bearer ")
        ) {
            return next(new ErrorStatus("Unauthorized", 401));
        }

        const token = auth_header.split(" ")[1];
        if (!token) {
            return next(new ErrorStatus("Unauthorized", 401));
        }

        try {
            // Verify token
            const verified = await jwtVerify(token, process.env.TOKEN_SECRET);
            req.token = token;

            // Session authentication
            if (opts.sessionAuth && verified.scope === "game") {
                return next();
            }

            // Lookup
            const tokenLookup = await Token.findOne({
                where: { token, scope: "auth" },
                attributes: ["revoked"],
                include: [
                    {
                        // @ts-ignore
                        model: User,
                        attributes: ["id", "role", "name"],
                    },
                ],
            });
            if (!tokenLookup || tokenLookup.revoked) {
                throw new ErrorStatus("Token revoked or missing", 403);
            }
            if (!tokenLookup.User) {
                throw new ErrorStatus("Bad token", 500);
            }

            req.user = tokenLookup.User;
            return next();
        } catch (err) {
            res.status(403);
            return next(err);
        }
    };
};
