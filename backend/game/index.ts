import { Server } from "socket.io";
import { GameHandler } from "./game";
import { Player } from "./session";

export const handler: GameHandler = new GameHandler();
export default (socketIO: Server) => {
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        try {
            // join & welcome
            handler.welcome(socketIO, socket);

            // answer
            socket.on("answer", (content: any) => {
                handler.answer(socketIO, socket, content);
            });

            // quit
            socket.on("quit", () => {
                handler.quit(socketIO, socket);
            });

            // start
            socket.on("start", () => {
                handler.start(socketIO, socket);
            });

            // abort
            socket.on("abort", () => {
                handler.abort(socketIO, socket);
            });

            // next question
            socket.on("next", () => {
                handler.next(socketIO, socket);
            });

            // showBoard
            socket.on("showBoard", () => {
                handler.showBoard(socketIO, socket);
            });

            // reset for debug
            socket.on("resetForDebug", () => {
                handler.checkEnv();
            });
        } catch (err) {
            if (process.env.NODE_EVN === "debug") {
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
