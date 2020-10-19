import { User as BackendUser } from "../models";
import { sessionTokenDecrypt as decrypt } from "../controllers/session";
import { Player, Session, Conn, QuizStatus, QuizResult } from "./session";
import { Answer } from "./points";
import { formatQuestion } from "./formatter";

import { Server, Socket } from "socket.io";

const WAITING = 10 * 1000;
const userCache: { [key: number]: Player } = {};

export class Game {
    // shaerd obj saves live quiz sess
    sessions: {
        [key: number]: Session;
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
            this.sessions[sessionId] = new Session(quiz, sessionId);
        }
    }

    addSession(quiz: any, sessionId: number) {
        this.sessions[sessionId] = new Session(quiz, sessionId);
        return this.sessions[sessionId].result;
    }

    /**
     *  Verify socket connection using jwt token
     * @param socket socket
     */
    async verifySocket(socket: Socket): Promise<Conn> {
        if (process.env.NODE_ENV === "debug") {
            const userId = Number(socket.handshake.query.userId);
            return new Conn(await this.getUserInfo(userId), {
                scope: "game",
                userId: userId,
                role: userId === 1 ? "host" : "participant",
                sessionId: 19,
            });
        }
        const plain = await decrypt(socket.handshake.query.token);
        const conn: Conn = new Conn(
            await this.getUserInfo(plain.userId),
            plain
        );
        return conn;
    }

    async answer(socketIO: Server, socket: Socket, content: any) {
        try {
            const conn: Conn = await this.verifySocket(socket);
            const sessionId = conn.sessionToken.sessionId;
            const userId = conn.player.id;
            const questionId = content.questionId;

            // check if already answered
            if (
                this.sessions[sessionId].isCurrQuestionActive() &&
                !this.sessions[sessionId].hasPlayerAnswered(userId)
            ) {
                try {
                    // if not answer yet, i.e. this is the first time to answer
                    // assess answer
                    const ans: Answer = new Answer(
                        content.question,
                        content.MCSelection,
                        content.TFSelection
                    );
                    this.sessions[sessionId].assessAns(userId, ans);

                    // braodcast that one more participants answered this question
                    socket.to(sessionId.toString()).emit("questionAnswered", {
                        question: questionId,
                        count: this.sessions[sessionId].pointSys.answeredPlayer
                            .size,
                        total: this.sessions[sessionId].countParticipants(),
                    });

                    const hasAllAnswered = this.sessions[
                        sessionId
                    ].trySettingForNewQuesiton();
                    if (hasAllAnswered) {
                        this.sessions[sessionId].rankBoard();
                    }
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

    // WIP: release question outcome after timeout
    /**
     * Everyone has answered or timeout
     * @param socketIO
     */
    releaseQuestionOutcome(socketIO: Server, conn: Conn) {
        const sessionId = conn.sessionToken.sessionId;
        const questionOutCome = {};
        // WIP: summary question outcome here

        // braodcast question outcome
        socketIO
            .to(sessionId.toString())
            .emit("questionOutcome", questionOutCome);
    }

    async welcome(socketIO: Server, socket: Socket) {
        try {
            const conn: Conn = await this.verifySocket(socket);
            const sessionId = conn.sessionToken.sessionId;
            const userId = conn.player.id;
            if (this.sessions[sessionId] === undefined) {
                socket.disconnect();
                return;
            }

            // add user to socket room
            socket.join(sessionId.toString());
            // add user to session
            const alreadyJoined = await this.sessions[sessionId].hasParticipant(
                userId
            );
            if (!this.isOwner(conn) && !alreadyJoined) {
                await this.sessions[sessionId].addParticipant(
                    await this.getUserInfo(userId),
                    socket
                );
                // broadcast that user has joined
                const msg = await this.getUserInfo(userId);
                socketIO.to(sessionId.toString()).emit("playerJoin", msg);
            }

            socket.emit(
                "welcome",
                Array.from(this.sessions[sessionId].allParticipants())
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
            const conn: Conn = await this.verifySocket(socket);
            const sessionId = conn.sessionToken.sessionId;
            const userId = conn.sessionToken.userId;

            // remove this participants from session in memory
            await this.sessions[sessionId].removeParticipant(userId, socket);
            // leave from socket room
            socket.leave(sessionId.toString());

            // WIP: Remove this participants from this quiz in DB records here

            // broadcast that user has left
            const msg = await this.getUserInfo(userId);
            socketIO.to(sessionId.toString()).emit("playerLeave", msg);
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

    private isOwner(conn: Conn) {
        return conn.sessionToken.role === "host";
    }

    async start(socketIO: Server, socket: Socket) {
        try {
            const conn: Conn = await this.verifySocket(socket);
            const sessionId = conn.sessionToken.sessionId;
            if (this.isOwner(conn)) {
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
            const conn: Conn = await this.verifySocket(socket);
            const sessionId = conn.sessionToken.sessionId;
            if (this.isOwner(conn)) {
                // WIP: Deactivate this quiz in DB records here

                // Broadcast that quiz has been aborted
                socketIO.to(sessionId.toString()).emit("cancelled", null);
                this.sessions[sessionId].close();
                socket.disconnect();
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
            const conn: Conn = await this.verifySocket(socket);
            const sessionId = conn.sessionToken.sessionId;
            if (this.isOwner(conn)) {
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
                                this.showBoard(socketIO, socket);
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

    async showBoard(socketIO: Server, socket: Socket) {
        try {
            // NOTE: get quizId and userId from decrypted token
            // Record it somewhere (cache or socket.handshake)
            // * token will expire in 1 hour

            const conn: Conn = await this.verifySocket(socket);
            const sessionId = conn.sessionToken.sessionId;

            if (
                this.isOwner(conn) &&
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
            const user = new Player(userId, res.name, res.pictureId);
            userCache[userId] = user;
            return user;
        }
    }
}
