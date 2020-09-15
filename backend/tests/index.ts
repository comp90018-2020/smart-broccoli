import server, { app } from "../server";

before(async () => {
    // Wait for server to start
    await server;
});

// Import tests
import "./auth.test";

export default app;
