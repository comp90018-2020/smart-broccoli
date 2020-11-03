import express, { Request, Response, NextFunction } from "express";
import helmet from "helmet";
import bodyParser from "body-parser";
import swaggerJSDoc from "swagger-jsdoc";
import swaggerUI from "swagger-ui-dist";
import fs from "fs";
import path from "path";
import router from "./routers";
import ErrorStatus from "./helpers/error";
import { generateDemoData } from "./demo";

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
            title: "smart-broccoli server",
            version: "1.0.0",
        },
    },
    apis: ["./routers/*.js", "./routers/*.ts"],
};
const swaggerSpec: any = swaggerJSDoc(options);

// Serve JSDoc and Swagger UI
app.get("/swagger.json", (req, res) => {
    // Add security at top level
    swaggerSpec["security"] = [{ bearerAuth: [] }];
    res.json(swaggerSpec);
});
app.get(["/", "/index.html"], (req, res, next) => {
    fs.readFile(
        path.join(swaggerUI.getAbsoluteFSPath(), "index.html"),
        (err, data) => {
            if (err) return next(err);
            res.send(
                data
                    .toString()
                    .replace(
                        "https://petstore.swagger.io/v2/swagger.json",
                        "swagger.json"
                    )
                    .replace(
                        "<title>Swagger UI</title>",
                        "<title>Smart Broccoli</title>"
                    )
            );
        }
    );
});
app.get("/swagger-ui.css", (req, res, next) => {
    fs.readFile(
        path.join(swaggerUI.getAbsoluteFSPath(), "swagger-ui.css"),
        (err, data) => {
            if (err) return next(err);
            res.contentType("swagger-ui.css");
            res.send(data + ".download-url-wrapper{display: none !important;}");
        }
    );
});
app.use(express.static(swaggerUI.getAbsoluteFSPath()));

// Router
app.use(router);

// Initialise demo data if necessary
if (process.env.DEMO) {
    (async () => {
        await generateDemoData();
    })();
}

// 404 handler
app.use((req, res, next) => {
    res.status(404);
    return res.send({ message: "Route not found" });
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
