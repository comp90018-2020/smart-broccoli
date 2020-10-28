import { Socket } from "socket.io";
import { getUserSessionProfile } from "../controllers/user";
import { GameSession } from "./session";
import {
    formatQuestion,
    formatWelcome,
    formatQuestionOutcome,
    rankSlice,
} from "./formatter";
import { Event, Role, GameStatus, Player, Answer, GameType } from "./datatype";
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
                type: "live",
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

            if (session.canAnswer(player, answer)) {
                // assess answer
                session.assessAns(player.id, answer);

                // braodcast that question has been answered
                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.questionAnswered,
                    {
                        question: answer.questionNo,
                        count: session.pointSys.answeredPlayers.size,
                        total: Object.keys(session.playerMap).length,
                    }
                );

                if (session.hasAllPlayerAnswered()) {
                    // set session state
                    session.setToNextQuestion(session.getQuestionIndex());

                    if (session.isSelfPacedGroup()) {
                        await this.next(
                            session,
                            session.getQuestionIndex() + 1
                        );
                    }
                }
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async welcome(socket: Socket, session: GameSession, player: Player) {
        try {
            if (!session.hasUser(player)) {
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
                session.hostJoin(player);
            } else {
                this.disconnectPast(
                    session,
                    session.getPlayer(player.id),
                    player
                );
                session.playerJoin(player);
            }

            // emit welcome event
            emitToOne(
                socket.id,
                Event.welcome,
                formatWelcome(
                    player.role,
                    session.getStatus(),
                    session.playerMap
                )
            );

            if (session.isSelfPacedGroupAndHasNotStarted()) {
                // extends time
                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.starting,
                    WAIT_TIME_BEFORE_START.toString()
                );

                await session.setStatus(GameStatus.Starting);
                setTimeout(
                    async (session: GameSession) => {
                        if (
                            session.is(GameStatus.Starting) &&
                            session.canReleaseTheFirstQuestion()
                        ) {
                            await session.setStatus(GameStatus.Running);
                            session.setToNextQuestion(0);
                            await this.next(session, 0);
                        }
                    },
                    WAIT_TIME_BEFORE_START,
                    session
                );
            } else {
                if (session.isSelfPacedNotGroupAndPending()) {
                    this.start(session, player);
                } else if (session.is(GameStatus.Starting)) {
                    // if game is starting,
                    emitToOne(
                        socket.id,
                        Event.starting,
                        (session.QuestionReleaseAt[0] - Date.now()).toString()
                    );
                } else if (session.is(GameStatus.Running)) {
                    // if game is running, emit nextQuestion
                    if (session.canSendQuesionAfterReconnection()) {
                        emitToOne(
                            player.socketId,
                            Event.nextQuestion,
                            formatQuestion(
                                session.visibleQuestionIndex(),
                                session,
                                player.role === Role.host ? true : false
                            )
                        );

                        if (session.canEmitCorrectAnswer()) {
                            const correctAnswer = session.getAnsOfQuestion(
                                session.visibleQuestionIndex()
                            );
                            this.emitCorrectAnswer(player, correctAnswer);
                        }
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
            await session.playerLeave(player);
            // disconnect
            socket.disconnect();
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async start(session: GameSession, player: Player) {
        try {
            if (session.isEmitValid(player)) {
                return;
            }
            if (session.canStart(player)) {
                // set game status to starting
                await session.setStatus(GameStatus.Starting);
                // Broadcast that quiz will be started
                session.setQuestionReleaseTime(0, WAIT_TIME_BEFORE_START);
                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.starting,
                    (session.QuestionReleaseAt[0] - Date.now()).toString()
                );
                setTimeout(async () => {
                    // after time out
                    await session.setStatus(GameStatus.Running);
                    session.setToNextQuestion(0);
                    // release the firt question
                    await this.next(session, 0, player);
                }, WAIT_TIME_BEFORE_START);
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async abort(session: GameSession, player?: Player) {
        try {
            if (session.isEmitValid(player)) {
                return;
            }
            if (session.canAbort(player)) {
                // Broadcast that quiz has been aborted
                emitToRoom(whichRoom(session, Role.all), Event.cancelled, null);
                // end a session
                await this.endSession(session);
                // reset a sample session if is debug mode
                this.checkEnv();
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async endSession(session: GameSession) {
        await session.endSession();
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

    async next(session: GameSession, questionIndex: number, player?: Player) {
        try {
            if (session.isEmitValid(player)) {
                return;
            }

            if (session.canReleaseNextQuestion(player, questionIndex)) {
                session.setQuestionReleaseTime(
                    questionIndex,
                    session.getQuizTimeLimit()
                );
                session.freezeQuestion(questionIndex);
                emitToRoom(
                    whichRoom(session, Role.player),
                    Event.nextQuestion,
                    formatQuestion(questionIndex, session, false)
                );
                if (!session.isSelfPaced()) {
                    // send question with answer to the host
                    emitToRoom(
                        whichRoom(session, Role.host),
                        Event.nextQuestion,
                        formatQuestion(questionIndex, session, true)
                    );
                }
                setTimeout(
                    async (questionIndex: number) => {
                        session.unfreezeQuestion(questionIndex);
                        if (session.canSetToNextQuestion(questionIndex)) {
                            await this.releaseCorrectAnswer(
                                session,
                                questionIndex,
                                player
                            );
                            session.setToNextQuestion(questionIndex);
                        }
                    },
                    process.env.SOCKET_MODE === "debug"
                        ? 10000
                        : session.getQuizTimeLimit(),
                    questionIndex
                );
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

    async releaseCorrectAnswer(
        session: GameSession,
        questoinIndex: number,
        player?: Player
    ) {
        const correctAnswer = session.getAnsOfQuestion(questoinIndex);
        for (const player of Object.values(session.playerMap)) {
            this.emitCorrectAnswer(player, correctAnswer);
        }
        emitToRoom(
            whichRoom(session, Role.host),
            Event.correctAnswer,
            correctAnswer
        );
        if (session.hasMoreQuestions()) {
            session.setToNextQuestion(questoinIndex + 1);

            if (session.isSelfPacedGroup()) {
                await this.showBoard(session, questoinIndex);
            } else if (session.isSelfPacedNotGroup()) {
                setTimeout(async () => {
                    await this.next(session, questoinIndex + 1);
                }, BoardShowTime);
            }
        } else {
            await this.showBoard(session, questoinIndex);
            emitToRoom(whichRoom(session, Role.all), Event.end, null);
            await this.abort(session, player);
        }
    }
    async showBoard(
        session: GameSession,
        questionIndex: number,
        player?: Player
    ) {
        try {
            if (session.isEmitValid(player)) {
                return;
            }

            if (session.canShowBoard(player)) {
                //  get ranked records of players
                const rank = session.rankPlayers();
                const top5 = rankSlice(rank, 5);
                for (const player of Object.values(session.playerMap)) {
                    emitToOne(
                        player.socketId,
                        Event.questionOutcome,
                        formatQuestionOutcome(session, player, rank, top5)
                    );
                }
                if (session.isSelfPacedGroup()) {
                    if (session.hasMoreQuestions()) {
                        setTimeout(async () => {
                            await this.next(session, questionIndex + 1);
                        }, BoardShowTime);
                    } else {
                        emitToRoom(
                            whichRoom(session, Role.all),
                            Event.end,
                            null
                        );
                        setTimeout(async () => {
                            await this.abort(session);
                        }, BoardShowTime);
                    }
                } else {
                    //  emit questionOutcome to the host
                    emitToRoom(
                        whichRoom(session, Role.host),
                        Event.questionOutcome,
                        {
                            question: session.questionIndex,
                            leaderboard: rankSlice(rank),
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
