import { Server, Socket } from "socket.io";
import { GameHandler, sendErr } from "./game";
import { sessionTokenDecrypt, clearSessions } from "../controllers/session";
import { Player, Role } from "./datatype";
import { GameSession } from "./session";

export const handler: GameHandler = new GameHandler();
const SESSIONS_PURNING_INTERVAL = 300000;
export let _socketIO: Server;
export default async (socketIO: Server) => {
    // clear sessions that are not ended on startup
    await clearSessions();
    pruneSessions();
    _socketIO = socketIO;
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        try {
            const [success, session, player] = await verify(socket);
            if (!success) {
                socket.disconnect();
                return;
            }
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
                handler.abort(session, player);
            });

            // next question
            socket.on("next", () => {
                handler.releaseQuestion(
                    session,
                    session.getQuestionIndex(),
                    player
                );
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
        const decrypted = await sessionTokenDecrypt(
            socket.handshake.query.token
        );
        if (!decrypted)
            return { userId: undefined, sessionId: undefined, role: undefined };
        return { ...decrypted };
    }
};

const verify = async (
    socket: Socket
): Promise<[boolean, GameSession, Player]> => {
    const token = socket.handshake.query.token;
    // @ts-ignore
    if (!_socketIO.sockets.connected.hasOwnProperty(socket.id)) {
        _socketIO.sockets.connected[socket.id] = socket;
    }
    const { userId, sessionId, role } = await decrypt(socket);
    if (
        sessionId === undefined ||
        !handler.sessions.hasOwnProperty(Number(sessionId))
    ) {
        return [false, null, null];
    }
    const session = handler.sessions[Number(sessionId)];
    const player = await handler.createPlayer(socket, userId, sessionId, role);

    if (token && session.isTokenDeactivated(token)) return [false, null, null];

    return [true, session, player];
};

const pruneSessions = async () => {
    for (const sessionId of Object.keys(handler.sessions)) {
        const nowTime = Date.now();
        if (
            nowTime - handler.sessions[Number(sessionId)].updatedAt >
            SESSIONS_PURNING_INTERVAL
        ) {
            handler.sessions[Number(sessionId)].endSession();
            delete handler.sessions[Number(sessionId)];
        }
    }
    setTimeout(() => {
        pruneSessions();
    }, SESSIONS_PURNING_INTERVAL);
};
