import { Server, Socket } from "socket.io";
import { GameHandler, sendErr } from "./game";
import { sessionTokenDecrypt } from "../controllers/session";
import { Player, Role } from "./datatype";
import { GameSession } from "./session";

export let _socketIO: Server = null;
export const handler: GameHandler = new GameHandler();
const socketSessionMap: { [socketId: string]: GameSession } = {};
const socketPlayerMap: { [socketId: string]: Player } = {};

export default (socketIO: Server) => {
    _socketIO = socketIO;
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        try {
            const [session, player] = await verify(socket);

            // join & welcome
            handler.welcome(socket, session, player);

            // answer
            socket.on("answer", (content: any) => {
                handler.answer(content, session, player);
            });

            // quit
            socket.on("quit", () => {
                handler.quit(socket, session, player);
            });

            // start
            socket.on("start", () => {
                handler.start(session, player);
            });

            // abort
            socket.on("abort", () => {
                handler.abort(socket, session, player);
            });

            // next question
            socket.on("next", () => {
                handler.next(session, player);
            });

            // showBoard
            socket.on("showBoard", () => {
                handler.showBoard(session, player);
            });

            if (process.env.SOCKET_MODE === "debug") {
                // reset for debug
                socket.on("resetForDebug", () => {
                    handler.checkEnv();
                });
            }
        } catch (err) {
            delete _socketIO.sockets.connected[socket.id];
            sendErr(err, socket.id);
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

const verify = async (socket: Socket): Promise<[GameSession, Player]> => {
    // @ts-ignore
    if (!_socketIO.sockets.connected.hasOwnProperty()) {
        _socketIO.sockets.connected[socket.id] = socket;
    }
    let session: GameSession;
    let player: Player;
    if (!socketSessionMap.hasOwnProperty(socket.id)) {
        const { userId, sessionId, role } = await decrypt(socket);
        session = handler.sessions[Number(sessionId)];

        player = await handler.createPlayer(socket, userId, sessionId, role);
    } else {
        session = socketSessionMap[socket.id];
        player = socketPlayerMap[socket.id];
    }
    return [session, player];
};
