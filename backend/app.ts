import express, { Request, Response, NextFunction } from "express";
import helmet from "helmet";
import bodyParser from "body-parser";
import router from "./routers";
import ErrorStatus from "helpers/error";
import swaggerJSDoc from "swagger-jsdoc";
import swaggerUI from "swagger-ui-dist";

const app = express();

// Helmet, security headers
app.use(
    helmet({
        contentSecurityPolicy: {
            directives: {
                defaultSrc: ["'self'"],
                scriptSrc: ["'self'", "'unsafe-inline'"],
                imgSrc: ["'self'", "data:", "validator.swagger.io"],
                styleSrc: ["'self'", "'unsafe-inline'", "fonts.googleapis.com"],
                fontSrc: ["fonts.gstatic.com"],
            },
        },
    })
);

// Body parser middleware
app.use(bodyParser.json());

// Swagger
// Generate spec from JSDoc
const options = {
    definition: {
        openapi: "3.0.0",
        info: {
            title: "fuzzy-broccoli server",
            version: "1.0.0",
        },
    },
    apis: ["./routers/*.js", "./routers/*.ts"],
};
const swaggerSpec = swaggerJSDoc(options);

// Serve JSDoc and Swagger UI
app.get("/swagger.json", (req, res) => {
    res.json(swaggerSpec);
});
app.use(express.static(swaggerUI.getAbsoluteFSPath()));

// Router
app.use(router);

// 404 handler
app.use((req, res, next) => {
    res.status(404);
    return res.send();
});

// Error handler
app.use((err: ErrorStatus, req: Request, res: Response, next: NextFunction) => {
    // Only provide stack trace in development
    const response: { message?: string; errors?: any; stack?: string } = {};

    // Copy message and errors
    response.message = err.message;
    if (err.payload) {
        response.errors = err.payload;
    }
    // Copy stack
    if (req.app.get("env") === "development") {
        response.stack = err.stack;
    }
    // Set error status if applicable
    if (res.statusCode === 200) {
        if (err.status) {
            res.status(err.status);
        } else {
            res.status(500);
        }
    }

    // If unknown error has occurred, print error and set status code
    if (res.statusCode === 500) {
        console.error(err.stack);
    }

    // Send response
    res.json(response);
});

export default app;
