import { NextFunction, Response, Request } from "express";
import { validationResult } from "express-validator";
import ErrorStatus from "../../helpers/error";

const validate = (req: Request, res: Response, next: NextFunction) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        const err = new ErrorStatus("Validation error", 400, errors.array());
        return next(err);
    }
    return next();
};
export default validate;
