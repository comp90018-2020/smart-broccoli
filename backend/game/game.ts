import { Socket } from "socket.io";
import { getUserSessionProfile } from "../controllers/user";
import { GameSession } from "./session";
import {
    formatQuestion,
    formatWelcome,
    formatQuestionOutcome,
} from "./formatter";
import { activateSession } from "../controllers/session";
import { Event, Role, GameStatus, Player, Answer, GameType } from "./datatype";
import { QuizAttributes } from "models/quiz";
import { _socketIO } from "./index";
import { threadId } from "worker_threads";

const WAIT_TIME_BEFORE_START = 10 * 1000;
const WAIT_TIME_SELFPACED_GROUP = 60 * 1000;
const RESET_SELFPACED_GROUP_TIME = 10 * 1000;
const CORRECT_ANSWER_SHOW_TIME = 3 * 1000;
const BOARD_SHOW_TIME = 5 * 1000;

export class GameHandler {
    sessions: {
        [key: number]: GameSession;
    };

    constructor() {
        this.sessions = {};
        this.checkEnv();
    }

    public checkEnv() {
        if (process.env.SOCKET_MODE === "debug") {
            console.log("[-] Debug mode.");
            const sessionId = 19;
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
        if (process.env.SOCKET_MODE === "debug") {
            const userId = Number(socket.handshake.query.userId);
            return new Player(
                userId,
                userId.toString(),
                null,
                socket.id,
                19,
                Number(userId) === 1 ? Role.host : Role.player,
                null
            );
        }

        const { name, pictureId } = await getUserSessionProfile(userId);

        return new Player(
            userId,
            name,
            pictureId,
            socket.id,
            sessionId,
            role,
            socket.handshake.query.token
        );
    }

    answer(content: any, session: GameSession, player: Player) {
        try {
            session.updatingTime();
            // create answer from emit
            const answer: Answer = new Answer(
                content.question,
                content.MCSelection,
                content.TFSelection
            );

            const currentQuestionIndex = session.getQuestionIndex();
            if (session.canAnswer(player, answer, currentQuestionIndex)) {
                // assess answer
                session.assessAns(player.id, answer);

                // braodcast that question has been answered
                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.questionAnswered,
                    {
                        question: answer.question,
                        count: Object.keys(session.pointSys.answers).length,
                        total: Object.keys(session.playerMap).length,
                    }
                );
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async welcome(socket: Socket, session: GameSession, player: Player) {
        try {
            // Update the time this session be accessed
            session.updatingTime();

            if (!session.hasUser(player))
                // If this player was not in this game
                // emit a playerJoin event
                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.playerJoin,
                    player.profile()
                );

            // Disconnect the existed player/host with the same player id if any
            this.disconnectExistSocket(session, player);
            // Player/host joins this game
            // And also copy the previous records if any
            session.playerJoin(player);

            // Add player/host to the socket room of the role
            socket.join(whichRoom(session, player.role));
            // Add player/host to the socket room of this game
            socket.join(whichRoom(session, Role.all));

            // Emit welcome event
            emitToOne(
                socket.id,
                Event.welcome,
                formatWelcome(player.role, session.status, session.playerMap)
            );

            if (session.isSelfPacedGroupAndHasNotStarted()) {
                // If this is a self-paced & group game
                // And has not stated yet

                if (session.status === GameStatus.Pending) {
                    // If game is Pending

                    // Set game status to starting
                    session.status = GameStatus.Starting;
                    // Set the timestamp that the first question will be released
                    session.setQuestionReleaseTime(
                        0,
                        WAIT_TIME_SELFPACED_GROUP
                    );

                    // Emit starting event with WAIT_TIME_BEFORE_START microseconds
                    emitToRoom(
                        whichRoom(session, Role.all),
                        Event.starting,
                        WAIT_TIME_SELFPACED_GROUP.toString()
                    );
                } else {
                    // If game is starting
                    // Get current time
                    const currentTime = Date.now();
                    // Get how much time from now 
                    // to when the first question should be released
                    const timeDifference =
                        session.questionReleaseAt[0] - currentTime;
                    if (
                        // If the releasing time is in the future
                        timeDifference > 0 &&
                        // And is less than RESET_SELFPACED_GROUP_TIME ms
                        timeDifference < RESET_SELFPACED_GROUP_TIME
                    ) {
                        // Reset the timestamp that the first question will be released
                        session.setQuestionReleaseTime(
                            0,
                            RESET_SELFPACED_GROUP_TIME
                        );
                        // Emit starting event with WAIT_TIME_BEFORE_START microseconds
                        emitToRoom(
                            whichRoom(session, Role.all),
                            Event.starting,
                            RESET_SELFPACED_GROUP_TIME.toString()
                        );
                    }
                }

                setTimeout(
                    // After timeout
                    async (session: GameSession) => {
                        // Check if can release the first question
                        // Because the time to release may be reset by new join
                        if (
                            // If this game is starting
                            session.is(GameStatus.Starting) &&
                            // And can release the first question
                            session.canReleaseTheFirstQuestion()
                        ) {
                            // Set the status to be Running
                            session.status = GameStatus.Running;
                            // Allow to release the first question
                            session.setToNextQuestion(0);
                            // Release the first question
                            this.releaseQuestion(session, 0);
                        }
                    },
                    WAIT_TIME_BEFORE_START,
                    session
                );
                return;
            } else if (session.isSelfPacedNotGroupAndHasNotStarted()) {
                // Else, if the game is self-paced and not group
                // and has not started yet, release the first question
                // without waiting in Starting status
                this.releaseQuestion(session, 0);
                return;
            }

            // If this is self-paced game but has started
            // Or this is live game
            if (session.is(GameStatus.Starting)) {
                // If this game is starting
                // Note, self-paced and not group game does not has starting status
                // Thus, self-paced and not group game can not reach this block

                // Emit a Starting event
                emitToOne(
                    socket.id,
                    Event.starting,
                    (session.questionReleaseAt[0] - Date.now()).toString()
                );
                return;
            }
            // If this is self-paced game but has started or this is live game
            if (session.is(GameStatus.Running)) {
                // And this game is running
                if (session.canSendQuesionAfterReconnection()) {
                    // If can release the question after reconnection
                    // Emit a nextQuestion event which carries the question
                    emitToOne(
                        player.socketId,
                        Event.nextQuestion,
                        formatQuestion(
                            session.visibleQuestionIndex(),
                            session,
                            player.role === Role.host
                        )
                    );

                    if (session.canEmitCorrectAnswer()) {
                        // If the corrct answer can also be released
                        // Get the correct answer
                        const correctAnswer = session.getAnsOfQuestion(
                            session.visibleQuestionIndex()
                        );
                        // Emit a correct answer event
                        this.emitCorrectAnswer(player, correctAnswer);
                    }
                }
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    /**
     * Disconnect socket with the same player id if any
     * @param session GameSession
     * @param player Player
     */
    disconnectExistSocket(session: GameSession, player: Player) {
        if (
            // If this is host
            player.role === Role.host &&
            // And there is a existed host
            session.host !== null &&
            // And that socket id is different from this one
            session.host.socketId !== player.socketId &&
            // And that socket id is connected
            _socketIO.sockets.connected.hasOwnProperty(
                session.playerMap[player.id].socketId
            )
        ) {
            // Disconnect the existed one
            _socketIO.sockets.connected[session.host.socketId].disconnect();
            return;
        }
        if (
            // If this is a player
            // And if exists socket connection with same player id
            session.playerMap[player.id] !== null &&
            // And that socket is is different from this one
            session.playerMap[player.id].socketId !== player.socketId &&
            // And that socket id is connected
            _socketIO.sockets.connected.hasOwnProperty(
                session.playerMap[player.id].socketId
            )
        ) {
            // Disconnect the existed one
            _socketIO.sockets.connected[
                session.playerMap[player.id].socketId
            ].disconnect();
        }
    }

    async quit(socket: Socket, session: GameSession, player: Player) {
        try {
            session.updatingTime();
            // Host should not use this
            if (player.role === Role.host) return;
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
            if (session.host === null && session.activePlayersNum === 0)
                this.abort(session);

            session.deactivateToken(player.token);
            // disconnect
            socket.disconnect(true);
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    async start(session: GameSession, player: Player) {
        try {
            // Update the time this session be accessed
            session.updatingTime();
            // Check if this emit is valid to access this code block
            if (!session.isEmitValid(player)) return;

            if (session.canStart(player)) {
                // If the session can be started now
                // Set game status to be Starting
                session.status = GameStatus.Starting;

                // Set the timestamp when the first question will be released
                if (session.isSelfPacedGroup())
                    // If this is self-paced group game
                    session.setQuestionReleaseTime(
                        0,
                        WAIT_TIME_SELFPACED_GROUP
                    );
                // Otherwise
                else session.setQuestionReleaseTime(0, WAIT_TIME_BEFORE_START);

                // Emit starting event
                emitToRoom(
                    whichRoom(session, Role.all),
                    Event.starting,
                    (session.questionReleaseAt[0] - Date.now()).toString()
                );

                // Release the first question after timeout
                setTimeout(async () => {
                    // After time out, set game status to be Running
                    session.status = GameStatus.Running;
                    // Allow the first question to be released
                    session.setToNextQuestion(0);
                    // Release the firt question
                    this.releaseQuestion(session, 0, player);
                }, WAIT_TIME_BEFORE_START);
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    abort(session: GameSession, player?: Player) {
        try {
            session.updatingTime();
            if (!session.isEmitValid(player)) return;

            if (session.canAbort(player)) {
                if (session.answerReleased.size < session.totalQuestions)
                    // Broadcast that quiz has been cancelled
                    emitToRoom(
                        whichRoom(session, Role.all),
                        Event.cancelled,
                        null
                    );
                else emitToRoom(whichRoom(session, Role.all), Event.end, null);

                // end a session
                this.endSession(session);
                // reset a sample session if is debug mode
                this.checkEnv();
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
        }
    }

    endSession(session: GameSession) {
        session.endSession();
        delete this.sessions[session.id];
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

    async releaseQuestion(
        session: GameSession,
        questionIndex: number,
        player?: Player
    ) {
        try {
            session.updatingTime();
            if (!session.isEmitValid(player)) return;
            if (session.canReleaseNextQuestion(player, questionIndex)) {
                session.pointSys.playersCountInThisQuestion =
                    session.activePlayersNum;
                session.setQuestionReleaseTime(
                    questionIndex,
                    session.getQuizTimeLimit()
                );
                session.freezeQuestion(questionIndex);

                // Activate session in controller
                // just before releasing the first question
                if (process.env.SOCKET_MODE !== "debug" && questionIndex === 0)
                    await activateSession(session.id);

                emitToRoom(
                    whichRoom(session, Role.player),
                    Event.nextQuestion,
                    formatQuestion(questionIndex, session, false)
                );
                session.questionReleased.add(questionIndex);
                if (!session.isSelfPaced()) {
                    // send question with answer to the host
                    emitToRoom(
                        whichRoom(session, Role.host),
                        Event.nextQuestion,
                        formatQuestion(questionIndex, session, true)
                    );
                }
                setTimeout(
                    (questionIndex: number) => {
                        this.releaseCorrectAnswer(session, questionIndex);
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
        const [record] = player.genreateRecord(correctAnswer.question);
        emitToOne(player.socketId, Event.correctAnswer, {
            answer: correctAnswer,
            record: record,
        });
    }

    releaseCorrectAnswer(session: GameSession, questionIndex: number) {
        // Rank player records when this question is end
        session.rankPlayers();
        const correctAnswer = session.getAnsOfQuestion(questionIndex);
        for (const player of Object.values(session.playerMap)) {
            this.emitCorrectAnswer(player, correctAnswer);
        }

        emitToRoom(
            whichRoom(session, Role.host),
            Event.correctAnswer,
            correctAnswer
        );

        session.answerReleased.add(questionIndex);
        session.setToNextQuestion(questionIndex + 1);

        if (session.isSelfPacedGroup()) {
            if (!session.hasFinalBoardReleased())
                setTimeout(() => {
                    this.showBoard(session);
                }, CORRECT_ANSWER_SHOW_TIME);
            return;
        }

        if (
            session.isSelfPacedNotGroup() &&
            session.questionIndex === session.totalQuestions
        )
            this.abort(session);
    }

    showBoard(session: GameSession, player?: Player) {
        try {
            session.updatingTime();
            if (!session.isEmitValid(player)) return;
            if (session.canShowBoard(player)) {
                const questionIndex = session.questionIndex - 1;
                //  get ranked records of players
                for (const player of Object.values(session.playerMap)) {
                    emitToOne(
                        player.socketId,
                        Event.questionOutcome,
                        formatQuestionOutcome(session, player, questionIndex)
                    );
                }
                //  emit questionOutcome to the host
                emitToRoom(
                    whichRoom(session, Role.host),
                    Event.questionOutcome,
                    {
                        question: session.questionIndex - 1,
                        leaderboard: session.rankedRecords.slice(0, 5),
                    }
                );
                session.boardReleased.add(session.questionIndex - 1);
                if (session.isSelfPacedGroup()) {
                    if (!session.hasFinalBoardReleased()) {
                        setTimeout(() => {
                            this.releaseQuestion(
                                session,
                                session.questionIndex
                            );
                        }, BOARD_SHOW_TIME);
                    } else this.abort(session);
                } else if (
                    !session.isSelfPacedNotGroup() &&
                    session.hasFinalBoardReleased()
                ) {
                    this.abort(session);
                }
            }
        } catch (error) {
            sendErr(error, player === undefined ? undefined : player.socketId);
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
