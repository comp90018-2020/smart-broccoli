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
const auth = async (req: Request, res: Response, next: NextFunction) => {
    // Examine header
    const auth_header = req.header("authorization");
    if (!auth_header || !auth_header.toLocaleLowerCase().includes("bearer ")) {
        const err = new ErrorStatus("Unauthorized", 401);
        return next(err);
    }

    const token = auth_header.split(" ")[1];
    if (!token) {
        const err = new ErrorStatus("Unauthorized", 401);
        return next(err);
    }

    try {
        // Verify token
        await jwtVerify(token, process.env.TOKEN_SECRET);

        // Lookup
        const tokenLookup = await Token.findOne({
            where: { token: token },
            include: ["User"],
        });
        if (!tokenLookup || tokenLookup.revoked) {
            const err = new ErrorStatus("Token revoked or missing", 403);
            throw err;
        }

        req.user = tokenLookup.User;
        req.token = token;
        return next();
    } catch (err) {
        res.status(403);
        return next(err);
    }
};

export { auth };
