import { Server, Socket } from "socket.io";
import { GameHandler, sendErr } from "./game";
import { sessionTokenDecrypt, clearSessions } from "../controllers/session";
import { Player, Role } from "./datatype";
import { GameSession } from "./session";

export const handler: GameHandler = new GameHandler();
const socketSessionMap: { [socketId: string]: GameSession } = {};
const socketPlayerMap: { [socketId: string]: Player } = {};

export let _socketIO: Server;
export default async (socketIO: Server) => {
    // clear sessions that are not ended on startup
    await clearSessions();

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
            await handler.welcome(socket, session, player);

            // answer
            socket.on("answer", async (content: any) => {
                await handler.answer(content, session, player);
            });

            // quit
            socket.on("quit", async () => {
                await handler.quit(socket, session, player);
            });

            // start
            socket.on("start", async () => {
                await handler.start(session, player);
            });

            // abort
            socket.on("abort", async () => {
                await handler.abort(session, player);
            });

            // next question
            socket.on("next", async () => {
                await handler.next(session, session.getQuestionIndex(), player);
            });

            // showBoard
            socket.on("showBoard", async () => {
                await handler.showBoard(session, session.questionIndex, player);
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

const verify = async (
    socket: Socket
): Promise<[boolean, GameSession, Player]> => {
    // @ts-ignore
    if (!_socketIO.sockets.connected.hasOwnProperty()) {
        _socketIO.sockets.connected[socket.id] = socket;
    }
    let session: GameSession;
    let player: Player;
    if (!socketSessionMap.hasOwnProperty(socket.id)) {
        const { userId, sessionId, role } = await decrypt(socket);
        if (!handler.sessions.hasOwnProperty(Number(sessionId))) {
            return [false, null, null];
        }
        session = handler.sessions[Number(sessionId)];
        player = await handler.createPlayer(socket, userId, sessionId, role);
    } else {
        session = socketSessionMap[socket.id];
        player = socketPlayerMap[socket.id];
    }
    return [true, session, player];
};
