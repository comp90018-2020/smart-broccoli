import { Socket } from "socket.io";
import { User as BackendUser } from "../models";
import { sessionTokenDecrypt as decrypt } from "../controllers/session";
import { Player, GameSession, GameStatus } from "./session";
import { Answer } from "./points";
import { formatQuestion, formatWelcome, formatPlayer } from "./formatter";
import { $socketIO } from "./index";

const WAITING = 10 * 1000;
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
        return true;
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

    async answer(socket: Socket, content: any) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];
            if (
                // current question is ready
                session.preQuestionIndex === session.questionIndex &&
                // this player has not answered
                !session.pointSys.answeredPlayer.has(player.id)
            ) {
                // assess answer
                const answer: Answer = new Answer(
                    content.question,
                    content.MCSelection,
                    content.TFSelection
                );
                session.assessAns(player.id, answer);

                // braodcast that question has been answered
                socket
                    .to(player.sessionId.toString())
                    .emit("questionAnswered", {
                        question: answer.questionNo,
                        count: session.pointSys.answeredPlayer.size,
                        total: this.sessions[
                            player.sessionId
                        ].countParticipants(),
                    });

                if (session.pointSys.hasAllPlayersAnswered()) {
                    session.moveToNextQuestion();
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
            const session = this.sessions[player.sessionId];
            if (session === undefined) {
                socket.disconnect();
                return;
            }

            // add user to socket room
            socket.join(player.sessionId.toString());
            // add user to session
            await session.addParticipant(await this.getUserInfo(player.id));
            if (
                player.role !== "host" &&
                !session.playerMap.hasOwnProperty(player.id)
            ) {
                // broadcast that user has joined
                const msg = await this.getUserInfo(player.id);
                socket.to(player.sessionId.toString()).emit("playerJoin", msg);
            }

            socket.emit("welcome", formatWelcome(session.allParticipants()));

            if (session.status === GameStatus.Starting) {
                socket.emit(
                    "starting",
                    (session.quizStartsAt - Date.now()).toString()
                );
            } else if (session.status === GameStatus.Running) {
                socket.emit("nextQuestion", session.currQuestion());
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

    async quit(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            // remove this participants from session in memory
            await session.removeParticipant(player);
            // leave from socket room
            socket.leave(player.sessionId.toString());

            // WIP: Remove this participants from this quiz in DB records here

            // broadcast that user has left
            $socketIO
                .to(player.sessionId.toString())
                .emit(
                    "playerLeave",
                    formatPlayer(await this.getUserInfo(player.id))
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

    async start(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (player.role === "host") {
                session.setQuizStatus(GameStatus.Starting);
                session.setQuizStartsAt(Date.now() + WAITING);
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
                        // release the firt question
                        this.next(socket);
                    },
                    process.env.NODE_ENV === "debug"
                        ? 1
                        : session.quizStartsAt - Date.now(),
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

    async next(socket: Socket) {
        try {
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (player.role === "host") {
                //  broadcast next question to participants
                if (session.status === GameStatus.Pending) {
                    this.start(socket);
                } else if (session.status === GameStatus.Starting) {
                    // nothing to do
                } else if (session.status === GameStatus.Running) {
                    try {
                        const questionIndex = this.sessions[
                            player.sessionId
                        ].nextQuestionIdx();
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
                        if (err === "no more question") {
                            if (session.hasFinalRankReleased === false) {
                                this.showBoard(socket);
                                this.sessions[
                                    player.sessionId
                                ].hasFinalRankReleased = true;
                            } else {
                                this.abort(socket);
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
            const player: Player = await this.verifySocket(socket);
            const session = this.sessions[player.sessionId];

            if (player.role === "host" && !session.isCurrQuestionActive()) {
                //  broadcast Board to participants
                session.releaseBoard(socket);
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
