#!/usr/bin/env node
import "./env";
import http from "http";
import app from "./app";
import sequelize from "./models";
import socket from "socket.io";
import io from "./game/index";

if (!process.env.TOKEN_SECRET) {
    console.error("TOKEN_SECRET not set, exiting...");
    process.exit(1);
}

// Get port from environment and store in Express
// istanbul ignore next
const port = process.env.PORT || "3000";
app.set("port", port);

// Create HTTP server
const server = http.createServer(app);
server.on("error", onError);
server.on("listening", onListening);

export default (async () => {
    // DB connection
    try {
        await sequelize.sync();
        console.log(
            `Postgres connection on ${sequelize.config.host}:${sequelize.config.port}`
        );
    } catch (err) {
        console.error(err);
        process.exit(1);
    }

    // socket.io server
    await io(socket(server));

    // Listen on provided port, on all network interfaces
    server.listen(port);
})();

// Event listener for HTTP server "error" event
// istanbul ignore next
function onError(error: NodeJS.ErrnoException) {
    if (error.syscall !== "listen") {
        throw error;
    }

    const bind = typeof port === "string" ? "Pipe " + port : "Port " + port;
    switch (error.code) {
        case "EACCES":
            console.error(bind + " requires elevated privileges");
            process.exit(1);
        case "EADDRINUSE":
            console.error(bind + " is already in use");
            process.exit(1);
        default:
            throw error;
    }
}

// Event listener for HTTP server "listening" event
function onListening() {
    const addr = server.address();
    // istanbul ignore next
    const bind =
        typeof addr === "string" ? "pipe " + addr : "port " + addr.port;
    console.log(`Express listening on ${bind}`);
}

export { app, io };
