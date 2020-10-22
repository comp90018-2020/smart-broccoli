import { Server } from "socket.io";
import { GameHandler } from "./game";

export let $socketIO: Server = null;
export const handler: GameHandler = new GameHandler();

export default (socketIO: Server) => {
    $socketIO = socketIO;
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        try {
            // join & welcome
            handler.welcome(socket);

            // answer
            socket.on("answer", (content: any) => {
                handler.answer(socket, content);
            });

            // quit
            socket.on("quit", () => {
                handler.quit(socket);
            });

            // start
            socket.on("start", () => {
                handler.start(socket);
            });

            // abort
            socket.on("abort", () => {
                handler.abort(socket);
            });

            // next question
            socket.on("next", () => {
                handler.next(socket);
            });

            // showBoard
            socket.on("showBoard", () => {
                handler.showBoard(socket);
            });

            if (process.env.SOCKET_MODE === "debug") {
                // reset for debug
                socket.on("resetForDebug", () => {
                    handler.checkEnv();
                });
            }
        } catch (err) {
            if (process.env.SOCKET_MODE === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(err, Object.getOwnPropertyNames(err))
                );
            }
            socket.disconnect();
        }

        return next();
    });
};
