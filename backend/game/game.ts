import { Socket } from "socket.io";
import { getUserSessionProfile } from "../controllers/user";
import { GameSession } from "./session";
import { formatQuestion, formatWelcome } from "./formatter";
import {
    Event,
    Role,
    Res,
    GameStatus,
    Player,
    Answer,
    GameType,
} from "./datatype";
import { QuizAttributes } from "models/quiz";
import { _socketIO } from "./index";

const WAIT_TIME_BEFORE_START = 10 * 1000;
const BoardShowTime = 5 * 1000;
const playerCache: { [userId: number]: Player } = {};
const socketPlayerMapCache: { [socketId: string]: Player } = {};

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
            const sessionId = 19;
            if (this.sessions.hasOwnProperty(sessionId)) {
                delete this.sessions[sessionId];
            }
            const quiz: QuizAttributes = {
                id: 19,
                title: "Fruits Master",
                active: true,
                description: "Test Quiz",
                type: "self paced",
                isGroup: false,
                timeLimit: 20,
                groupId: 2,
                pictureId: null,
                questions: [
                    {
                        id: 32,
                        text: "Is potato fruit?",
                        type: "truefalse",
                        tf: true,
                        options: null,
                        quizId: 19,
                        pictureId: null,
                        numCorrect: 1,
                    },
                    {
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
                        numCorrect: 1,
                    },
                    {
                        id: 34,
                        text: "Which one is fruit?",
                        type: "choice",
                        tf: null,
                        quizId: 19,
                        options: [
                            { text: "apple", correct: true },
                            { text: "Apple", correct: true },
                            { text: "rice", correct: false },
                            { text: "cola", correct: false },
                        ],
                        numCorrect: 2,
                    },
                ],
            };
            this.addSession(quiz, sessionId, quiz.type, quiz.isGroup);
        }
    }

    addSession(
        quiz: QuizAttributes,
        sessionId: number,
        quizType: string,
        isGroup: boolean
    ) {
        // @ts-ignore
        // const quizJSON: QuizAttributes = quiz.toJSON();
        const newSession = new GameSession(quiz, sessionId, quizType, isGroup);
        this.sessions[sessionId] = newSession;

        console.log(`[*] reset a game session(${newSession.type}) for debug`);
        return true;
    }

    /**
     *  Verify socket connection using jwt token
     * @param socket socket
     */
    async createPlayer(
        socket: Socket,
        userId: number,
        sessionId: number,
        role: string
    ): Promise<Player> {
        if (socketPlayerMapCache.hasOwnProperty(socket.id)) {
            return socketPlayerMapCache[socket.id];
        }
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
            socketPlayerMapCache[socket.id] = player;
            return player;
        } else {
            const player = await this.getUserInfo(
                userId,
                socket.id,
                sessionId,
                role
            );
            socketPlayerMapCache[socket.id] = player;
            return player;
        }
    }

    async answer(content: any, session: GameSession, player: Player) {
        try {
            // create answer from emit
            const answer: Answer = new Answer(
                content.question,
                content.MCSelection,
                content.TFSelection
            );

            if (answer.questionNo !== session.questionIndex) {
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
                emitToRoom(
                    whichRoom(session, Role.player),
                    Event.questionAnswered,
                    {
                        question: answer.questionNo,
                        count: session.pointSys.answeredPlayers.size,
                        total: Object.keys(session.playerMap).length,
                    }
                );

                if (
                    session.pointSys.answeredPlayers.size >=
                    Object.keys(session.playerMap).length
                ) {
                    // set session state
                    session.setToNextQuestion();

                    if (session.type == GameType.SelfPaced_Group) {
                        this.next(session);
                    }
                }
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async welcome(socket: Socket, session: GameSession, player: Player) {
        try {
            if (!session.playerMap.hasOwnProperty(player.id)) {
                // if not host, emit playerJoin
                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.playerJoin,
                    player.profile()
                );
            }

            // add user to socket room
            socket.join(whichRoom(session, player.role));
            socket.join(whichRoom(session, Role.all));
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
            emitToOne(
                socket.id,
                Event.welcome,
                formatWelcome(player.role, session.status, session.playerMap)
            );

            if (
                session.type === GameType.SelfPaced_Group &&
                (session.status === GameStatus.Pending ||
                    session.status === GameStatus.Starting)
            ) {
                // extends time
                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.starting,
                    WAIT_TIME_BEFORE_START.toString()
                );
                session.quizStartsAt = Date.now() + WAIT_TIME_BEFORE_START;

                setTimeout(
                    () => {
                        if (Date.now() > session.quizStartsAt) {
                            session.status = GameStatus.Running;
                            session.setToNextQuestion();
                            this.next(session);
                        }
                    },
                    WAIT_TIME_BEFORE_START + 1,
                    session
                );
            } else {
                if (session.status === GameStatus.Pending) {
                    if (session.type == GameType.SelfPaced_NotGroup) {
                        this.start(session, player);
                    }
                } else if (session.status === GameStatus.Starting) {
                    // if game is starting,
                    emitToOne(
                        socket.id,
                        Event.starting,
                        (session.quizStartsAt - Date.now()).toString()
                    );
                } else if (session.status === GameStatus.Running) {
                    // if game is running, emit nextQuestion
                    emitToOne(
                        player.socketId,
                        Event.nextQuestion,
                        formatQuestion(
                            session.questionIndex,
                            session,
                            player.role === Role.host ? true : false
                        )
                    );

                    if (
                        session.isReadyForNextQuestion &&
                        session.questionIndex >= 0 &&
                        session.questionIndex < session.quiz.questions.length
                    ) {
                        const correctAnswer = session.getAnsOfQuestion(
                            session.questionIndex
                        );
                        this.emitCorrectAnswer(player, correctAnswer);
                    }
                } else {
                    // otherwise ignore
                }
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    disconnectPast(session: GameSession, pastPlayer: Player, player: Player) {
        if (
            pastPlayer != null &&
            pastPlayer.socketId != player.socketId &&
            _socketIO.sockets.connected.hasOwnProperty(pastPlayer.socketId)
        ) {
            _socketIO.sockets.connected[pastPlayer.socketId].disconnect();
        }
    }

    async quit(socket: Socket, session: GameSession, player: Player) {
        try {
            // remove this participants from session in memory
            delete session.playerMap[player.id];
            // leave from socket room
            socket.leave(whichRoom(session, player.role));
            socket.leave(whichRoom(session, Role.all));
            // broadcast to other players
            emitToRoom(
                whichRoom(session, Role.all),
                Event.playerLeave,
                player.profile()
            );
            // disconnect
            socket.disconnect();
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async start(session: GameSession, player: Player) {
        try {
            if (
                session.type === GameType.SelfPaced_Group &&
                player !== undefined
            ) {
                return;
            }
            if (
                // and game is pending
                session.status == GameStatus.Pending &&
                // if no host or player is host
                (session.type === GameType.SelfPaced_Group ||
                    player.role === Role.host)
            ) {
                // set game status to starting
                session.status = GameStatus.Starting;
                // set the start time
                session.quizStartsAt = Date.now() + WAIT_TIME_BEFORE_START;
                // Broadcast that quiz will be started

                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.starting,
                    (session.quizStartsAt - Date.now()).toString()
                );
                setTimeout(
                    () => {
                        // after time out
                        session.status = GameStatus.Running;
                        session.setToNextQuestion();
                        // release the firt question
                        this.next(session, player);
                    },
                    process.env.SOCKET_MODE === "debug"
                        ? 1
                        : session.quizStartsAt - Date.now()
                );
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async abort(session: GameSession, player?: Player) {
        try {
            if (
                session.type === GameType.SelfPaced_Group &&
                player !== undefined
            ) {
                return;
            }
            if (
                session.type === GameType.SelfPaced_Group ||
                player.role === Role.host
            ) {
                // Broadcast that quiz has been aborted
                emitToRoom(whichRoom(session, Role.all), Event.cancelled, null);
                // end this session
                this.endSession(session);
                // reset a sample session if is debug mode
                this.checkEnv();
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    endSession(session: GameSession) {
        if (
            _socketIO !== undefined &&
            _socketIO.sockets.adapter.rooms.hasOwnProperty(
                whichRoom(session, Role.all)
            )
        ) {
            for (const socketId of Object.keys(
                _socketIO.sockets.adapter.rooms[whichRoom(session, Role.all)]
                    .sockets
            )) {
                // loop over socket in the room
                // and disconnect them
                if (_socketIO.sockets.connected.hasOwnProperty(socketId)) {
                    _socketIO.sockets.connected[socketId].disconnect();
                }
            }
        }
    }

    async next(session: GameSession, player?: Player) {
        try {
            if (
                session.type === GameType.SelfPaced_Group &&
                player !== undefined
            ) {
                return;
            }

            if (
                session.isReadyForNextQuestion &&
                // if no host or player is host
                (session.type === GameType.SelfPaced_Group ||
                    player.role === Role.host) &&
                session.status === GameStatus.Running
            ) {
                // try to get the index of next question
                const [res, questionIndex] = session.getNextQuestionIndex();
                if (res === Res.Success) {
                    emitToRoom(
                        whichRoom(session, Role.player),
                        Event.nextQuestion,
                        formatQuestion(questionIndex, session, false)
                    );
                    if (session.type !== GameType.SelfPaced_Group) {
                        // send question with answer to the host
                        emitToRoom(
                            whichRoom(session, Role.host),
                            Event.nextQuestion,
                            formatQuestion(questionIndex, session, true)
                        );
                    }
                    setTimeout(() => {
                        if (
                            session.nextQuestionIndex === session.questionIndex
                        ) {
                            session.setToNextQuestion();
                            this.releaseCorrectAnswer(session, questionIndex);

                            if (session.type === GameType.SelfPaced_NotGroup) {
                                this.showBoard(session, player);
                            }
                        }
                    }, session.quiz.timeLimit * 1000);
                } else {
                    // if failed to get next question index, print log
                    console.log(res);
                }
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    emitCorrectAnswer(player: Player, correctAnswer: Answer) {
        emitToOne(player.socketId, Event.correctAnswer, {
            answer: correctAnswer,
            record: player.formatRecord().record,
        });
    }

    releaseCorrectAnswer(session: GameSession, questoinIndex: number) {
        for (const player of Object.values(session.playerMap)) {
            this.emitCorrectAnswer(
                player,
                session.getAnsOfQuestion(questoinIndex)
            );
        }

        if (session.type === GameType.SelfPaced_Group) {
            this.showBoard(session);
        }

        if (session.questionIndex >= session.quiz.questions.length - 1) {
            emitToRoom(whichRoom(session, Role.all), Event.end, null);

            if (session.type === GameType.SelfPaced_Group) {
                setTimeout(() => {
                    this.abort(session);
                }, BoardShowTime * 10);
            }
        }
    }
    async showBoard(session: GameSession, player?: Player) {
        try {
            if (
                session.type === GameType.SelfPaced_Group &&
                player !== undefined
            ) {
                return;
            }

            if (
                session.isReadyForNextQuestion &&
                (session.type === GameType.SelfPaced_Group ||
                    player.role === Role.host)
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

                    emitToOne(socketId, Event.questionOutcome, questionOutcome);
                }
                if (session.type === GameType.SelfPaced_Group) {
                    if (
                        session.questionIndex <
                        session.quiz.questions.length - 1
                    ) {
                        setTimeout(() => {
                            if (session.isReadyForNextQuestion) {
                                this.next(session);
                            }
                        }, BoardShowTime);
                    } else {
                        setTimeout(() => {
                            this.abort(session);
                        }, BoardShowTime * 10);
                    }
                } else {
                    //  emit questionOutcome to the host
                    emitToRoom(
                        whichRoom(session, Role.host),
                        Event.questionOutcome,
                        {
                            question: session.questionIndex,
                            leaderboard: rank,
                        }
                    );
                }
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async getUserInfo(
        userId: number,
        socketId?: string,
        sessionId?: number,
        role?: string
    ): Promise<Player> {
        if (playerCache.hasOwnProperty(userId)) {
            const { name, pictureId, socketId, role } = playerCache[userId];
            return new Player(
                userId,
                name,
                pictureId,
                socketId,
                sessionId,
                role
            );
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
            playerCache[userId] = player;
            return player;
        }
    }
}

export const sendErr = (error: any, socketId: string) => {
    console.log(error);
    if (process.env.SOCKET_MODE === "debug") {
        // https://stackoverflow.com/questions/18391212
        if (
            socketId !== null &&
            _socketIO.sockets.connected.hasOwnProperty(socketId)
        ) {
            _socketIO.sockets.connected[socketId].send(
                JSON.stringify(error, Object.getOwnPropertyNames(error))
            );
            _socketIO.sockets.connected[socketId].disconnect();
        }
    }
};

export const whichRoom = (session: GameSession, role: string) => {
    return session.id.toString() + (role === undefined ? "" : role);
};

export const emitToOne = (socketId: string, event: Event, content: any) => {
    if (_socketIO.sockets.connected.hasOwnProperty(socketId)) {
        _socketIO.sockets.connected[socketId].emit(event, content);
    }
};

export const emitToRoom = (roomName: string, event: Event, content: any) => {
    if (_socketIO.sockets.adapter.rooms.hasOwnProperty(roomName)) {
        _socketIO.to(roomName).emit(event, content);
    }
};
