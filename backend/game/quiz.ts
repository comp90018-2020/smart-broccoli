import { User as BackendUser, Session as SessInController, Quiz as QuizInModels } from "../models";
import { sessionTokenDecrypt as decrypt } from "../controllers/session"
import { User, Session, Conn, QuizStatus } from "./session";
import { Server } from "socket.io";
import { Socket } from "dgram";


const WAITING = 10 * 1000;
const userCache: { [key: number]: User } = {};

export class Quiz {
    // shaerd obj saves live quiz sess
    sess: {
        [key: number]: Session
    };

    constructor() {
        this.sess = {};
        if (process.env.NODE_ENV === "debug") {
            console.log("[*] Debug mode.")
            this.DEBUG();
        }
    }

    private async DEBUG() {
        const quiz = await QuizInModels.findByPk(16, { include: ["questions"] })
        const sessInController = new SessInController({
            id: 19,
            isGroup: true,
            type: "live",
            state: "waiting",
            quizId: 16,
            groupId: 2,
            subscribeGroup: true,
            code: "501760"
        });
        this.sess[sessInController.id] = new Session(quiz, sessInController);
    }

    async addSession(quiz: any, s: SessInController): Promise<SessInController> {
        this.sess[s.id] = new Session(quiz, s);
        return this.sess[s.id].SessInController;
    }

    /**
     *  Verify socket connection using jwt token 
     * @param socket socket
     */
    async verifySocket(socket: SocketIO.Socket): Promise<Conn> {
        if (process.env.NODE_ENV === "debug") {
            const userId = Number(socket.handshake.query.userId);
            return new Conn(
                await this.getUserInfo(userId),
                {
                    scope: 'game',
                    userId: userId,
                    role: userId === 1 ? 'host' : 'participant',
                    sessionId: 19
                }
            );
        }
        const plain = await decrypt(socket.handshake.query.token);
        const conn: Conn = new Conn(await this.getUserInfo(plain.userId), plain);
        return conn;
    }


    private checkAnswer(quizId: number, answer: any) {
        const questionId = answer.question;
        const MCSelection = answer.MCSelection;
        const TFSelection = answer.TFSelection;
        const points = 0;
        // WIP: check answers for this question here 
        return points;
    }

    private recordPoints(userId: number, points: number) {
        // WIP: record points gained
    }


    private formatAnswered(quizId: number, questionId: number) {
        return {
            "question": questionId,
            "count": this.sess[quizId].getAnswered(),
            "total": this.sess[quizId].countParticipants()
        }
    }

    answer(socketIO: Server, content: any, conn: Conn) {
        // {
        //     "question": 3,
        //     "MCSelection": 0,  // list index of answer chosen (for MC Question)
        //     "TFSelection": true | false  // for TF question
        // }
        const sessId = conn.sessionToken.sessionId;
        const userId = conn.user.id;
        const questionId = content.questionId;

        // check if already answered
        const alreadyAnswerd = this.sess[sessId].hasPlayerAnswered(userId);
        if (!alreadyAnswerd) {
            // if not answer yet / this is the first time to answer
            const points = this.checkAnswer(sessId, content);
            this.recordPoints(userId, points);
            // record in session that player has answered
            this.sess[sessId].playerAnswered(userId);

            // braodcast that one more participants answered this question
            const answered = this.formatAnswered(sessId, questionId);
            socketIO.to(sessId.toString()).emit("questionAnswered", answered);

            // if everyone has answered
            if (answered.count >= this.sess[sessId].countParticipants()) {
                this.releaseQuestionOutcome(socketIO, conn);
            }
        }

    }

    // WIP: release question outcome after timeout
    /**
     * Everyone has answered or timeout
     * @param socketIO 
     */
    releaseQuestionOutcome(socketIO: Server, conn: Conn) {

        const sessId = conn.sessionToken.sessionId;;
        let questionOutCome = {};
        // WIP: summary question outcome here

        // braodcast question outcome
        socketIO.to(sessId.toString()).emit("questionOutcome", questionOutCome);
    }

    private welcomeMSG(sessionId: number) {
        // WIP: format welcome message here

        return Array.from(this.sess[sessionId].allParticipants());
    }

    async welcome(socketIO: Server, socket: SocketIO.Socket, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;
        const userId = conn.user.id;
        if (this.sess[sessId] === undefined) {
            socket.disconnect();
            return;
        }

        // add user to socket room
        socket.join(sessId.toString());
        // add user to session
        const alreadyJoined = await this.sess[sessId].hasParticipant(userId);
        if (!this.isOwner(conn) && !alreadyJoined) {
            await this.sess[sessId].addParticipant(await this.getUserInfo(userId), socket);
            // broadcast that user has joined
            const msg = await this.getUserInfo(userId);
            socketIO.to(sessId.toString()).emit("playerJoin", msg);

        }

        socket.emit("welcome", this.welcomeMSG(sessId));

        if (this.sess[sessId].getQuizStatus() === QuizStatus.Starting) {
            socket.emit("starting", (this.sess[sessId].getQuizStartsAt() - Date.now()).toString());
        }


    }

    async quit(socketIO: Server, socket: SocketIO.Socket, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;
        const userId = conn.sessionToken.userId;

        // remove this participants from session in memory
        await this.sess[sessId].removeParticipant(userId, socket);
        // leave from socket room
        socket.leave(sessId.toString());

        // WIP: Remove this participants from this quiz in DB records here

        // broadcast that user has left
        const msg = await this.getUserInfo(userId);
        socketIO.to(sessId.toString()).emit("playerLeave", msg);
        // disconnect
        socket.disconnect();
    }

    private isOwner(conn: Conn) {
        return conn.sessionToken.role === "host";
    }


    start(socketIO: Server, socket: SocketIO.Socket, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;
        if (this.isOwner(conn)) {

            this.sess[sessId].setQuizStatus(QuizStatus.Starting);
            this.sess[sessId].setQuizStartsAt(Date.now() + WAITING);
            // Broadcast that quiz will be started
            socketIO.to(sessId.toString()).emit("starting", (this.sess[sessId].getQuizStartsAt() - Date.now()).toString());
            // pass-correct-this-context-to-settimeout-callback
            // https://stackoverflow.com/questions/2130241
            setTimeout(() => {
                this.sess[sessId].setQuizStatus(QuizStatus.Running);
                // release the firt question
                this.nextQuestion(socketIO, socket, conn);
            }, this.sess[sessId].getQuizStartsAt() - Date.now(), socket);

        }
    }

    abort(socketIO: Server, socket: SocketIO.Socket, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;
        if (this.isOwner(conn)) {
            // WIP: Deactivate this quiz in DB records here

            // Broadcast that quiz has been aborted
            socketIO.to(sessId.toString()).emit("cancelled", null);
            this.sess[sessId].close();
            socket.disconnect();
        }

    }

    nextQuestion(socketIO: Server, socket: SocketIO.Socket, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;

        if (this.isOwner(conn)) {
            //  broadcast next question to participants
            if (this.sess[sessId].getQuizStartsAt() === 0) {
                this.start(socketIO, socket, conn);
            } else if (this.sess[sessId].getQuizStartsAt() - Date.now() <= 0) {
                try {
                    const qIdx = this.sess[sessId].nextQuestionIdx();
                    // send question without answer to participants
                    socket.to(sessId.toString()).emit("nextQuestion", this.sess[sessId].getQuestion(qIdx));
                    socketIO.to(socket.id).emit("nextQuestion", this.sess[sessId].getQuestionWithAns(qIdx));

                }
                catch (err) {
                    if (err === "no more question") {
                        if (this.sess[sessId].hasFinalBoardReleased === false) {
                            this.showBoard(socketIO, conn);
                            this.sess[sessId].hasFinalBoardReleased = true;
                        } else {
                            this.abort(socketIO, socket, conn);
                        }
                    } else if (err === "there is a running question") {

                    }
                    else {

                    }
                }
            }

        }
    }

    private formatBoard(quizId: number) {
        let leaderboard = [{ "this is leaderboard": "wohhoo" }];
        // WIP: format leaderborad here

        return leaderboard;
    }

    showBoard(socketIO: Server, conn: Conn) {
        // NOTE: get quizId and userId from decrypted token
        // Record it somewhere (cache or socket.handshake)
        // * token will expire in 1 hour
        const sessId = conn.sessionToken.sessionId;;

        if (this.isOwner(conn)) {
            //  broadcast Board to participants
            socketIO.to(sessId.toString()).emit("questionOutcome", this.formatBoard(sessId));
        }
    }

    async getUserInfo(userId: number): Promise<User> {
        if (userCache.hasOwnProperty(userId)) {
            return userCache[userId];
        } else {
            const res = await BackendUser.findByPk(userId, {
                attributes: ["name", "pictureId"],
            });
            const user = new User(userId, res.name, res.pictureId);
            userCache[userId] = user;
            return user;
        }
    }

}



