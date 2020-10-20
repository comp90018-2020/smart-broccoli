import { User as BackendUser } from "../models";
import { sessionTokenDecrypt as decrypt } from "../controllers/session";
import { Player, GameSession, QuizStatus, QuizResult } from "./session";
import { Answer } from "./points";
import { formatQuestion, formatWelcome, formatPlayer } from "./formatter";

import { Server, Socket } from "socket.io";
import { $socketIO } from "./index"

const WAITING = 10 * 1000;
const userCache: { [key: number]: Player } = {};

export class GameHandler {
    // shaerd obj saves live quiz sess
    sessions: {
        [key: number]: GameSession;
    };

    constructor() {
        this.sessions = {};
        this.checkEnv();
    }

    public async checkEnv() {
        if (process.env.NODE_ENV === "debug") {
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

    addSession(quiz: any, sessionId: number) {
        this.sessions[sessionId] = new GameSession(quiz, sessionId);
        return this.sessions[sessionId].result;
    }

    /**
     *  Verify socket connection using jwt token
     * @param socket socket
     */
    async verifySocket(socket: Socket): Promise<Player> {
        if (process.env.NODE_ENV === "debug") {
            const player = await this.getUserInfo(
                Number(socket.handshake.query.userId)
            );
            player.socketId = socket.id;
            player.sessionId = 19;
            player.role = Number(player.id) === 1 ? "host" : "participant";
            return player;
        } else {
            const plain = await decrypt(socket.handshake.query.token);
            const player = await this.getUserInfo(Number(plain.userId));
            const { userId, scope, role, sessionId } = await decrypt(
                socket.handshake.query.token
            );
            player.socketId = socket.id;
            player.sessionId = sessionId;
            player.role = role;
            return player;
        }
    }

    async answer(socketIO: Server, socket: Socket, content: any) {
        try {
            const player: Player = await this.verifySocket(socket);
            const sessionId = player.sessionId;
            const userId = player.id;
            const questionId = content.questionId;

            // check if already answered
            if (
                this.sessions[sessionId].isCurrQuestionActive() &&
                !this.sessions[sessionId].hasPlayerAnswered(userId)
            ) {
                try {
                    // if not answer yet, i.e. this is the first time to answer
                    // assess answer
                    const answer: Answer = new Answer(
                        content.question,
                        content.MCSelection,
                        content.TFSelection
                    );
                    // this.sessions[sessionId].assessAns(userId, answer);

                    // braodcast that one more participants answered this question
                    socket.to(sessionId.toString()).emit("questionAnswered", {
                        question: questionId,
                        count: this.sessions[sessionId].pointSys.answeredPlayer
                            .size,
                        total: this.sessions[sessionId].countParticipants(),
                    });

                    this.sessions[sessionId].trySettingForNewQuesiton();
                } catch (err) {
                    if (process.env.NODE_EVN === "debug") {
                        socket.send(
                            JSON.stringify(err, Object.getOwnPropertyNames(err))
                        );
                    }
                }
            }
        } catch (error) {
            if (process.env.NODE_EVN === "debug") {
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
            const sessionId = player.sessionId;
            const userId = player.id;
            if (this.sessions[sessionId] === undefined) {
                socket.disconnect();
                return;
            }

            // add user to socket room
            socket.join(sessionId.toString());
            // add user to session
            await this.sessions[sessionId].addParticipant(await this.getUserInfo(userId));
            if (player.role !== "host") {
                
                // broadcast that user has joined
                const msg = await this.getUserInfo(userId);
                socket.to(sessionId.toString()).emit("playerJoin", msg);
            }

            socket.emit(
                "welcome",
                formatWelcome(this.sessions[sessionId].allParticipants())
            );

            if (this.sessions[sessionId].status === QuizStatus.Starting) {
                socket.emit(
                    "starting",
                    (
                        this.sessions[sessionId].getQuizStartsAt() - Date.now()
                    ).toString()
                );
            }

            if (this.sessions[sessionId].status === QuizStatus.Running) {
                socket.emit(
                    "nextQuestion",
                    this.sessions[sessionId].currQuestion()
                );
            }
        } catch (error) {
            if (process.env.NODE_EVN === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async quit(socketIO: Server, socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const sessionId = player.sessionId;
            const userId = player.sessionId;

            // remove this participants from session in memory
            await this.sessions[sessionId].removeParticipant(player);
            // leave from socket room
            socket.leave(sessionId.toString());

            // WIP: Remove this participants from this quiz in DB records here

            // broadcast that user has left
            socketIO
                .to(sessionId.toString())
                .emit(
                    "playerLeave",
                    formatPlayer(await this.getUserInfo(userId))
                );
            // disconnect
            socket.disconnect();
        } catch (error) {
            if (process.env.NODE_EVN === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async start(socketIO: Server, socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const sessionId = player.sessionId;
            if (player.role === "host") {
                this.sessions[sessionId].setQuizStatus(QuizStatus.Starting);
                this.sessions[sessionId].setQuizStartsAt(Date.now() + WAITING);
                // Broadcast that quiz will be started
                socketIO
                    .to(sessionId.toString())
                    .emit(
                        "starting",
                        (
                            this.sessions[sessionId].getQuizStartsAt() -
                            Date.now()
                        ).toString()
                    );
                // pass-correct-this-context-to-settimeout-callback
                // https://stackoverflow.com/questions/2130241
                setTimeout(
                    () => {
                        this.sessions[sessionId].status = QuizStatus.Running;
                        // release the firt question
                        this.next(socketIO, socket);
                    },
                    // this.sessions[sessionId].getQuizStartsAt() - Date.now(),
                    1,
                    socket
                );
            }
        } catch (error) {
            if (process.env.NODE_EVN === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async abort(socketIO: Server, socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const sessionId = player.sessionId;
            if (player.role === "host") {
                // Broadcast that quiz has been aborted
                socketIO.to(sessionId.toString()).emit("cancelled", null);
                this.sessions[sessionId].close(socketIO, socket);
                this.checkEnv();
            }
        } catch (error) {
            if (process.env.NODE_EVN === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async next(socketIO: Server, socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const sessionId = player.sessionId;
            if (player.role === "host") {
                //  broadcast next question to participants
                if (this.sessions[sessionId].status === QuizStatus.Pending) {
                    this.start(socketIO, socket);
                } else if (
                    this.sessions[sessionId].status === QuizStatus.Starting
                ) {
                    // nothing to do
                } else if (
                    this.sessions[sessionId].status === QuizStatus.Running
                ) {
                    try {
                        const questionIndex = this.sessions[
                            sessionId
                        ].nextQuestionIdx();
                        // send question without answer to participants
                        socket
                            .to(sessionId.toString())
                            .emit(
                                "nextQuestion",
                                formatQuestion(
                                    questionIndex,
                                    this.sessions[sessionId],
                                    false
                                )
                            );

                        // send question with answer to the host
                        socketIO
                            .to(socket.id)
                            .emit(
                                "nextQuestion",
                                formatQuestion(
                                    questionIndex,
                                    this.sessions[sessionId],
                                    true
                                )
                            );
                    } catch (err) {
                        if (err === "no more question") {
                            if (
                                this.sessions[sessionId]
                                    .hasFinalBoardReleased === false
                            ) {
                                this.showBoard(socket);
                                this.sessions[
                                    sessionId
                                ].hasFinalBoardReleased = true;
                            } else {
                                this.abort(socketIO, socket);
                            }
                        } else if (err === "there is a running question") {
                        } else {
                        }
                    }
                }
            }
        } catch (error) {
            if (process.env.NODE_EVN === "debug") {
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
            // NOTE: get quizId and userId from decrypted token
            // Record it somewhere (cache or socket.handshake)
            // * token will expire in 1 hour

            const player: Player = await this.verifySocket(socket);
            const sessionId = player.sessionId;

            if (
                player.role === "host" &&
                !this.sessions[sessionId].isCurrQuestionActive()
            ) {
                //  broadcast Board to participants
                this.sessions[sessionId].releaseBoard(socket);
            }
        } catch (error) {
            if (process.env.NODE_EVN === "debug") {
                // https://stackoverflow.com/questions/18391212
                socket.send(
                    JSON.stringify(error, Object.getOwnPropertyNames(error))
                );
            }
            socket.disconnect();
        }
    }

    async getUserInfo(userId: number): Promise<Player> {
        if (userCache.hasOwnProperty(userId)) {
            return userCache[userId];
        } else {
            const res = await BackendUser.findByPk(userId, {
                attributes: ["name", "pictureId"],
            });
            const player = new Player(
                userId,
                res.name,
                res.pictureId,
                null,
                null,
                null
            );
            userCache[userId] = player;
            return player;
        }
    }
}
