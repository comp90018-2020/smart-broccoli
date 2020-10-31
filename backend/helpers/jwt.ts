import jwt from "jsonwebtoken";

/**
 * Sign JWT token.
 * @param payload Data to sign
 * @param secret Secret key
 * @param options jwt.SignOptions
 */
const jwtSign = (
    payload: object,
    secret: string,
    options?: jwt.SignOptions
): Promise<string> => {
    return new Promise((resolve, reject) => {
        jwt.sign(payload, secret, options, (err, token) => {
            if (err) return reject(err);
            return resolve(token);
        });
    });
};

/**
 * Verify JWT token.
 * @param token Data to sign
 * @param secret Secret key
 */
const jwtVerify = (token: string, secret: string): Promise<any> => {
    return new Promise((resolve, reject) => {
        jwt.verify(token, secret, function (err, decoded) {
            if (err) {
                return reject(err);
            }
            return resolve(decoded);
        });
    });
};

export { jwtSign, jwtVerify };
