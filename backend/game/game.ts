import { Socket } from "socket.io";
import { sessionTokenDecrypt as decrypt } from "../controllers/session";
import { getUserSessionProfile } from "../controllers/user";
import { GameSession } from "./session";
import { formatQuestion, formatWelcome } from "./formatter";
import { $socketIO } from "./index";
import { Role, Res, GameStatus, Player, Answer } from "./datatype";
import { Quiz, Question } from "../models";
import { endSession } from "../controllers/session";

const WAIT_TIME_BEFORE_START = 10 * 1000;
const userCache: { [key: number]: Player } = {};

export class GameHandler {
    sessions: {
        [key: number]: GameSession;
    };

    constructor() {
        this.sessions = {};
        this.checkEnv();
    }

    public async checkEnv() {
        if (process.env.SOCKET_MODE === "debug") {
            console.log("[-] Debug mode.");
            console.log("[*] reset a game session for debug");
            const sessionId = 19;
            if (this.sessions.hasOwnProperty(sessionId)) {
                delete this.sessions[sessionId];
            }
            const quiz = new Quiz({
                id: 19,
                title: "Fruits Master",
                active: true,
                description: "Test Quiz",
                type: "live",
                timeLimit: 20,
                groupId: 2,
                pictureId: null,
                questions: [
                    new Question({
                        id: 32,
                        text: "Is potato fruit?",
                        type: "truefalse",
                        tf: true,
                        options: null,
                        quizId: 19,
                        pictureId: null,
                    }),
                    new Question({
                        id: 33,
                        text: "A, B, C, D?",
                        type: "choice",
                        tf: null,
                        quizId: 19,
                        options: [
                            { correct: true, text: "A" },
                            { correct: false, text: "B" },
                            { correct: false, text: "C" },
                            { correct: false, text: "D" },
                        ],
                    }),
                    new Question({
                        id: 34,
                        text: "Which ones is fruit?",
                        type: "choice",
                        tf: null,
                        quizId: 19,
                        options: [
                            { text: "apple", correct: true },
                            { text: "Apple", correct: true },
                            { text: "rice", correct: false },
                            { text: "cola", correct: false },
                        ],
                    }),
                ],
            });
            this.sessions[sessionId] = new GameSession(quiz, sessionId);
        }
    }

    addSession(quiz: Quiz, sessionId: number) {
        this.sessions[sessionId] = new GameSession(quiz, sessionId);
        return true;
    }

    /**
     *  Verify socket connection using jwt token
     * @param socket socket
     */
    async verifySocket(socket: Socket): Promise<Player> {
        if (process.env.SOCKET_MODE === "debug") {
            const userId = Number(socket.handshake.query.userId);
            const player = new Player(
                userId,
                userId.toString(),
                null,
                socket.id,
                19,
                Number(userId) === 1 ? Role.host : Role.player
            );
            return player;
        } else {
            const plain = await decrypt(socket.handshake.query.token);
            const player = await this.getUserInfo(
                plain.userId,
                socket.id,
                plain.sessionId,
                plain.role
            );
            return player;
        }
    }

    async answer(socket: Socket, content: any) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            // create answer from emit
            const answer: Answer = new Answer(
                content.question,
                content.MCSelection,
                content.TFSelection
            );

            if (answer.questionNo == session.questionIndex) {
                // ignore the emit with not matched quetion number
                return;
            }

            if (
                // is player
                player.role === Role.player &&
                // and there is a conducting question
                !session.isReadyForNextQuestion &&
                // and this player has not answered
                !session.pointSys.answeredPlayers.has(player.id)
            ) {
                // assess answer
                session.assessAns(player.id, answer);

                // braodcast that question has been answered
                socket
                    .to(player.sessionId.toString())
                    .emit("questionAnswered", {
                        question: answer.questionNo,
                        count: session.pointSys.answeredPlayers.size,
                        total: Object.keys(session.playerMap).length,
                    });

                if (
                    session.pointSys.answeredPlayers.size >=
                    Object.keys(session.playerMap).length
                ) {
                    // set session state
                    session.setToNextQuestion();
                }
            }
        } catch (error) {
            sendErr(error, socket);
            socket.disconnect();
        }
    }

    async welcome(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (
                player.role !== Role.host &&
                !session.playerMap.hasOwnProperty(player.id)
            ) {
                // if not host, emit playerJoin
                socket
                    .to(player.sessionId.toString())
                    .emit("playerJoin", player.profile());
            }

            // add user to socket room
            socket.join(player.sessionId.toString());
            // add user to session
            if (player.role === Role.host) {
                this.disconnectPast(session, session.host, player);
                session.host = player;
            } else {
                this.disconnectPast(
                    session,
                    session.playerMap[player.id],
                    player
                );
                session.playerMap[player.id] = player;
            }

            // emit welcome event
            socket.emit("welcome", formatWelcome(session.playerMap));

            if (session.status === GameStatus.Starting) {
                // if game is starting, emit starting
                socket.emit(
                    "starting",
                    (session.quizStartsAt - Date.now()).toString()
                );
            } else if (session.status === GameStatus.Running) {
                // if game is running, emit nextQuestion
                socket.emit(
                    "nextQuestion",
                    formatQuestion(
                        session.questionIndex,
                        session,
                        player.role === Role.host ? true : false
                    )
                );
            } else {
                // otherwise ignore
            }
        } catch (error) {
            sendErr(error, socket);
            socket.disconnect();
        }
    }

    disconnectPast(session: GameSession, pastPlayer: Player, player: Player) {
        if (
            pastPlayer != null &&
            pastPlayer.socketId != player.socketId &&
            $socketIO.sockets.connected.hasOwnProperty(pastPlayer.socketId)
        ) {
            $socketIO.sockets.connected[pastPlayer.socketId].disconnect();
        }
    }

    async quit(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            // remove this participants from session in memory
            delete session.playerMap[player.id];
            // leave from socket room
            socket.leave(player.sessionId.toString());
            // broadcast to other players
            socket
                .to(player.sessionId.toString())
                .emit("playerLeave", player.profile());
            // disconnect
            socket.disconnect();
        } catch (error) {
            sendErr(error, socket);
            socket.disconnect();
        }
    }

    async start(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (
                // if is host
                player.role === Role.host &&
                // and game is pending
                session.status == GameStatus.Pending
            ) {
                // set game status to starting
                session.status = GameStatus.Starting;
                // set the start time
                session.quizStartsAt = Date.now() + WAIT_TIME_BEFORE_START;
                // Broadcast that quiz will be started
                $socketIO
                    .to(player.sessionId.toString())
                    .emit(
                        "starting",
                        (session.quizStartsAt - Date.now()).toString()
                    );
                setTimeout(
                    () => {
                        // after time out
                        session.status = GameStatus.Running;
                        session.setToNextQuestion();
                        // release the firt question
                        this.next(socket);
                    },
                    process.env.SOCKET_MODE === "debug"
                        ? 1
                        : session.quizStartsAt - Date.now(),
                    socket
                );
            }
        } catch (error) {
            sendErr(error, socket);
            socket.disconnect();
        }
    }

    async abort(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (player.role === Role.host) {
                // Broadcast that quiz has been aborted
                $socketIO
                    .to(player.sessionId.toString())
                    .emit("cancelled", null);

                // end this session
                this.endSession(session);
                // reset a sample session if is debug mode
                this.checkEnv();
            }
        } catch (error) {
            sendErr(error, socket);
            socket.disconnect();
        }
    }

    endSession(session: GameSession) {
        for (const socketId of Object.keys(
            $socketIO.sockets.adapter.rooms[session.sessionId.toString()]
                .sockets
        )) {
            // loop over socket in the room
            // and disconnect them
            $socketIO.sockets.connected[socketId].disconnect();
        }
    }

    async next(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (
                player.role === Role.host &&
                session.status === GameStatus.Running
            ) {
                // try to get the index of next question
                const [res, questionIndex] = session.nextQuestionIdx();
                if (res === Res.Success) {
                    // allow host move to next question if currentlly there is
                    // no player in the
                    if (Object.keys(session.playerMap).length <= 0) {
                        session.setToNextQuestion();
                    }
                    // send question without answer to participants
                    socket
                        .to(player.sessionId.toString())
                        .emit(
                            "nextQuestion",
                            formatQuestion(questionIndex, session, false)
                        );

                    // send question with answer to the host
                    socket.emit(
                        "nextQuestion",
                        formatQuestion(questionIndex, session, true)
                    );
                } else {
                    // if failed to get next question index, print log
                    console.log(res);
                }
            }
        } catch (error) {
            sendErr(error, socket);
            socket.disconnect();
        }
    }

    async showBoard(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (
                player.role === Role.host &&
                session.questionIndex !== session.nextQuestionIndex
            ) {
                //  get ranked records of players
                const rank = session.rankPlayers();

                for (const { id, socketId, record } of Object.values(
                    session.playerMap
                )) {
                    // get player ahead
                    const playerAheadRecord =
                        record.newPos === null || record.newPos === 0
                            ? null
                            : rank[record.newPos - 1];
                    // form question outcome
                    const questionOutcome = {
                        question: session.questionIndex,
                        leaderboard: rank.slice(0, 5),
                        record: session.playerMap[Number(id)].formatRecord()
                            .record,
                        playerAhead: playerAheadRecord,
                    };
                    // emit questionOutcome to participants
                    $socketIO
                        .to(socketId)
                        .emit("questionOutcome", questionOutcome);
                }

                // emit questionOutcome to the host
                socket.emit("questionOutcome", {
                    question: session.questionIndex,
                    leaderboard: rank,
                });
            }
        } catch (error) {
            sendErr(error, socket);
            socket.disconnect();
        }
    }

    async getUserInfo(
        userId: number,
        socketId?: string,
        sessionId?: number,
        role?: string
    ): Promise<Player> {
        if (userCache.hasOwnProperty(userId)) {
            return userCache[userId];
        } else {
            const { name, pictureId } = await getUserSessionProfile(userId);
            const player = new Player(
                userId,
                name,
                pictureId,
                socketId,
                sessionId,
                role
            );
            userCache[userId] = player;
            return player;
        }
    }
}

export const sendErr = (error: any, socket: Socket) => {
    if (process.env.SOCKET_MODE === "debug") {
        // https://stackoverflow.com/questions/18391212
        socket.send(JSON.stringify(error, Object.getOwnPropertyNames(error)));
    }
};
