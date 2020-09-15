import jwt from "jsonwebtoken";

// Sign JWT token
const jwtSign = (payload: object, secret: string): Promise<string> => {
    return new Promise((resolve, reject) => {
        jwt.sign(payload, secret, (err, token) => {
            if (err) return reject(err);
            return resolve(token);
        });
    });
};

// Verify JWT token
const jwtVerify = (token: string, secret: string) => {
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
