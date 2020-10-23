import { Socket } from "socket.io";
import { sessionTokenDecrypt as decrypt } from "../controllers/session";
import { getUserSessionProfile } from "../controllers/user";
import { GameSession } from "./session";
import { formatQuestion, formatWelcome } from "./formatter";
import { $socketIO } from "./index";
import { GameErr, GameStatus, Player, Answer } from "./datatype";
import Quiz from "../models/quiz";

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
            const quiz = JSON.parse(
                '{"id":19,"title":"Fruits Master","active":true,"description":"Test Quiz","type":"live","timeLimit":20,"createdAt":"2020-10-15T07:42:47.905Z","updatedAt":"2020-10-15T07:42:47.905Z","pictureId":null,"groupId":2,"questions":[{"id":32,"text":"Is potato fruit?","type":"truefalse","tf":true,"options":null,"createdAt":"2020-10-15T07:42:47.927Z","updatedAt":"2020-10-15T07:42:47.927Z","quizId":19,"pictureId":null},{"id":33,"text":"Is potato fruit?","type":"truefalse","tf":true,"options":null,"createdAt":"2020-10-15T07:42:47.935Z","updatedAt":"2020-10-15T07:42:47.935Z","quizId":19,"pictureId":null},{"id":34,"text":"Which one is fruit?","type":"choice","tf":null,"options":[{"text":"apple","correct":true},{"text":"Apple","correct":false},{"text":"rice","correct":false},{"text":"cola","correct":false}],"createdAt":"2020-10-15T07:42:47.939Z","updatedAt":"2020-10-15T07:42:47.939Z","quizId":19,"pictureId":null}]}'
            );
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
                Number(userId) === 1 ? "host" : "participant"
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
            if (
                // this player has not answered
                !session.pointSys.answeredPlayers.has(player.id) &&
                // the question is conducting
                !session.isReadyForNextQuestion
            ) {
                const answer: Answer = new Answer(
                    content.question,
                    content.MCSelection,
                    content.TFSelection
                );
                if (answer.questionNo != session.questionIndex) {
                    // quetion number is not right
                    return;
                }
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
            if (process.env.SOCKET_MODE === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async welcome(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];
            // add user to socket room
            socket.join(player.sessionId.toString());
            if (
                player.role !== "host" &&
                !session.playerMap.hasOwnProperty(player.id)
            ) {
                socket
                    .to(player.sessionId.toString())
                    .emit("playerJoin", player.profile());
            }
            // add user to session
            session.addParticipant(player);

            socket.emit("welcome", formatWelcome(session.playerMap));

            if (session.status === GameStatus.Starting) {
                socket.emit(
                    "starting",
                    // make it more precise
                    (session.quizStartsAt - Date.now()).toString()
                );
            } else if (session.status === GameStatus.Running) {
                // there is question released
                socket.emit(
                    "nextQuestion",
                    formatQuestion(
                        session.questionIndex,
                        session,
                        player.role === "host" ? true : false
                    )
                );
            }
        } catch (error) {
            if (process.env.SOCKET_MODE === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async quit(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            // remove this participants from session in memory
            await session.removeParticipant(player, true);
            // leave from socket room
            socket.leave(player.sessionId.toString());

            // WIP: Remove this participants from this quiz in DB records here

            // broadcast that user has left
            $socketIO
                .to(player.sessionId.toString())
                .emit("playerLeave", player.profile());
            // disconnect
            socket.disconnect();
        } catch (error) {
            if (process.env.SOCKET_MODE === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async start(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (
                player.role === "host" &&
                session.status == GameStatus.Pending
            ) {
                session.status = GameStatus.Starting;
                session.quizStartsAt = Date.now() + WAIT_TIME_BEFORE_START;
                // Broadcast that quiz will be started
                $socketIO
                    .to(player.sessionId.toString())
                    .emit(
                        "starting",
                        (session.quizStartsAt - Date.now()).toString()
                    );
                // pass-correct-this-context-to-settimeout-callback
                // https://stackoverflow.com/questions/2130241
                setTimeout(
                    () => {
                        session.status = GameStatus.Running;
                        session.isReadyForNextQuestion = true;
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
            if (process.env.SOCKET_MODE === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async abort(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (player.role === "host") {
                // Broadcast that quiz has been aborted
                $socketIO
                    .to(player.sessionId.toString())
                    .emit("cancelled", null);
                session.close($socketIO, socket);

                // reset a sample session under debug mode
                this.checkEnv();
            }
        } catch (error) {
            if (process.env.SOCKET_MODE === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async next(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (player.role === "host") {
                //  broadcast next question to participants
                if (session.status === GameStatus.Pending) {
                    this.start(socket);
                } else if (session.status === GameStatus.Starting) {
                    // nothing to do, ignore this event
                } else if (session.status === GameStatus.Running) {
                    try {
                        const questionIndex = session.nextQuestionIdx();

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
                        $socketIO
                            .to(socket.id)
                            .emit(
                                "nextQuestion",
                                formatQuestion(questionIndex, session, true)
                            );
                    } catch (err) {
                        if (err === GameErr.NoMoreQuestion) {
                            if (session.hasFinalRankReleased === false) {
                                this.showBoard(socket);
                                session.hasFinalRankReleased = true;
                            } else {
                                this.abort(socket);
                            }
                        } else if (err === GameErr.ThereIsRunningQuestion) {
                            console.log(err);
                        } else {
                            console.log(err);
                        }
                    }
                }
            }
        } catch (error) {
            if (process.env.SOCKET_MODE === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async showBoard(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (player.role === "host" && !session.isCurrQuestionActive()) {
                //  broadcast Board to participants
                session.releaseBoard(socket);
            }
        } catch (error) {
            if (process.env.SOCKET_MODE === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
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