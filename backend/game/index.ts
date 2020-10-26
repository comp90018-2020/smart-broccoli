import { Server } from "socket.io";
import { GameHandler, sendErr } from "./game";
import { sessionTokenDecrypt } from "../controllers/session";
import { Player, Role } from "./datatype";

export let socketIO_: Server = null;
export const handler: GameHandler = new GameHandler();

export default (socketIO: Server) => {
    socketIO_ = socketIO;
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        try {
            const { userId, sessionId, role } = await decrypt(socket);
            const player: Player = await handler.createPlayer(
                socket,
                userId,
                sessionId,
                role
            );
            const session = handler.sessions[Number(sessionId)];

            // join & welcome
            handler.welcome(socket, session, player);

            // answer
            socket.on("answer", (content: any) => {
                handler.answer(socket, content, session, player);
            });

            // quit
            socket.on("quit", () => {
                handler.quit(socket, session, player);
            });

            // start
            socket.on("start", () => {
                handler.start(socket, session, player);
            });

            // abort
            socket.on("abort", () => {
                handler.abort(socket, session, player);
            });

            // next question
            socket.on("next", () => {
                handler.next(socket, session, player);
            });

            // showBoard
            socket.on("showBoard", () => {
                handler.showBoard(socket, session, player);
            });

            if (process.env.SOCKET_MODE === "debug") {
                // reset for debug
                socket.on("resetForDebug", () => {
                    handler.checkEnv();
                });
            }
        } catch (err) {
            sendErr(err, socket);
            socket.disconnect();
        }

        return next();
    });
};

const decrypt = async (socket: SocketIO.Socket) => {
    if (process.env.SOCKET_MODE === "debug") {
        const userId = Number(socket.handshake.query.userId);
        const sessionId = 19;
        const role = userId === 1 ? Role.host : Role.player;
        return { userId, sessionId, role };
    } else {
        const { userId, sessionId, role } = await sessionTokenDecrypt(
            socket.handshake.query.token
        );
        return { userId, sessionId, role };
    }
};
