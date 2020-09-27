import server, { app } from "../server";
import fs from "fs";

// Remove directory promise
const rmdir = (path: string) => {
    return new Promise((resolve) => {
        fs.rmdir(path, { recursive: true }, () => {
            return resolve();
        });
    });
};

before(async () => {
    // Remove upload directory
    await rmdir("uploads/");
    fs.mkdirSync("uploads/profile", { recursive: true });
    fs.mkdirSync("uploads/question", { recursive: true });

    // Wait for server to start
    await server;
});

// Import tests
// import "./auth.test";
// import "./user.test";
// import "./group.test";
import "./quiz.test";

export default app;
