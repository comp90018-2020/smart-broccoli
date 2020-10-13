import { jwtVerify } from "../helpers/jwt";
import { User as BackendUser, Session as SessInController } from "../models";
import { sessionTokenDecrypt as decrypt, SessionToken } from "../controllers/session"
import { ENUM } from "sequelize/types";


const WAITING = 10 * 1000;
const userCache: { [key: number]: User } = {};

enum AnswerStatus {
    NoAnswered = 0,
    Answered = 1
}

enum GameStatus {
    InGame = 0,
    Left = 1
}

class PlayerStatus {
    answer: AnswerStatus;
    game: GameStatus;

    constructor($answer: AnswerStatus, $game: GameStatus) {
        this.answer = $answer;
        this.game = $game;
    }
}

enum QuizStatus {
    Pending = 0,
    Starting = 1,
    Running = 2,
    Ended = 3
}

class User {
    readonly id: number;
    readonly name: string;
    readonly picturId: number;

    constructor($id: number, $name: string, $picturId: number) {
        this.id = $id;
        this.name = $name;
        this.picturId = $picturId;
    }
}

class Option {
    constructor(
        readonly correct: boolean,
        readonly text: string
    ) { };
}


class Question {
    constructor(
        readonly no: number,
        readonly text: string,
        readonly pictureId: boolean,
        readonly options: Option[] | null,
        readonly tf: boolean | null,
        readonly time: number,
    ) { }
}
export class Conn {
    constructor(
        readonly user: User,
        readonly sessionToken: SessionToken
    ) { }
}

export class Session {
    readonly id: number;
    sess: SessInController;
    private status: QuizStatus;
    private quizStartsAt = 0;
    private participants: any;
    private participantsNames: { [key: string]: any };
    private questions: Question[];
    private sockets: any;
    private questionIdx = 0;
    private questionReleasedAt = 0;
    private questionPanel: {
        [key: string]: PlayerStatus
    };

    constructor($quiz: any, $s: SessInController) {
        this.id = $s.id;
        this.sess = $s;
        this.participants = new Set([]);
        this.participantsNames = {};
        this.sockets = new Set();
        this.questionPanel = {};
        this.status = QuizStatus.Pending;
        // TODO: format questions 
        this.setQuestions($quiz, $s);
    }

    async addParticipant(user: User, socket: SocketIO.Socket) {
        this.participants.add(user.id);
        this.participantsNames[user.id] = user.name;
        this.sockets.add(socket);
        this.questionPanel[user.id] = new PlayerStatus(AnswerStatus.NoAnswered, GameStatus.InGame);
    }

    async removeParticipant(userId: number, socket: SocketIO.Socket) {
        this.participants.delete(userId);
        delete this.participantsNames[userId];
        this.sockets.delete(socket);
        this.questionPanel[userId].game = GameStatus.Left;
    }

    async hasParticipant(userId: number) {
        return this.participants.has(userId);
    }

    countParticipants(): number {
        return this.participants.size;
    }

    allParticipants() {
        let ret = new Set([]);
        for (const [key, value] of Object.entries(this.participantsNames)) {
            ret.add(value);
        }
        return ret;
    }

    playerAnswered(userId: number) {
        this.questionPanel[userId].answer = AnswerStatus.Answered;
    }

    /**
     * return the count of answered users which are still in game
     */
    getAnswered(): number {
        let count = 0;
        for (const [key, value] of Object.entries(this.questionPanel)) {
            if (value.answer == AnswerStatus.Answered && value.game == GameStatus.InGame) {
                ++count;
            }
        }
        return count;
    }

    hasPlayerAnswered(userId: number) {
        return this.questionPanel[userId].answer === AnswerStatus.Answered;
    }

    hasPlayerLeft(userId: number) {
        return this.questionPanel[userId].game === GameStatus.Left;
    }

    private resetQuestionPanel() {
        this.questionPanel = {};
    }

    /**
     * Set questions list of this session
     * @param questions questions list
     */
    private async setQuestions(quiz: any, s: SessInController) {
        // TODO: format questions that can be sent to players here
        const questions: Question[] = [];
        let i = 0;
        while (quiz.questions.length > 0) {
            const q = quiz.questions.shift();
            console.log(q);
            const question = new Question(
                i++,
                q.text,
                q.pictureId,
                q.options,
                q.tf,
                quiz.timeLimit);
            questions.push(question);
        }
        this.questions = questions;

        console.log(this.questions);
    }

    /**
     * If a connection is lost and subsequently restored during a quiz, 
     * send current question immediately (corresponding to the current question; 
     * update time field).
     */
    currQuestion() {
        const { no, text, pictureId, options, tf, time } = this.questions[this.questionIdx];
        const currQuestion = new Question(no, text, pictureId, options, tf,
            time - (Date.now() - this.questionReleasedAt));
        return currQuestion;
    }

    nextQuestion(): Object {
        if (this.questionIdx < this.questions.length) {
            this.resetQuestionPanel();
            this.questionReleasedAt = Date.now();
            return this.questions[this.questionIdx++];
        } else {
            return undefined;
        }
    }

    setQuizStatus(status: QuizStatus) {
        this.status = status;
    }

    getQuizStatus() {
        return this.status;
    }

    setQuizStartsAt(timestamp: number) {
        this.quizStartsAt = timestamp;
    }

    getQuizStartsAt() {
        return this.quizStartsAt;
    }

    close() {
        this.sockets.forEach((s: SocketIO.Socket) => {
            s.disconnect();
        });
        this.participants = new Set();
    }

}

export class LiveQuiz {
    // shaerd obj saves live quiz sess
    sess: {
        [key: number]: Session
    };

    constructor() {
        this.sess = {};
        // // DEBUG ===>
        // let s = new SessInController();
        // this.addSession(s);
        // // DEBUG <===
    }

    async addSession(quiz: any, s: SessInController): Promise<SessInController> {
        this.sess[s.id] = new Session(quiz, s);
        return this.sess[s.id].sess;
    }

    /**
     *  Verify socket connection using jwt token 
     * @param socket socket
     */
    async verifySocket(socket: SocketIO.Socket): Promise<Conn> {
        let plain: SessionToken;
        if (process.env.NODE_EVN == 'production') {
            plain = await decrypt(socket.handshake.query.token);
        } else {
            // for test
            plain = {
                "scope": "game",
                "userId": 1,
                "role": "host",
                "sessionId": 123
            };
        }

        const conn: Conn = new Conn(await this.getUserInfo(plain.userId), plain);
        // jwtVerify(socket.handshake.query.token, this.secret);
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

    answer(socket: SocketIO.Socket, content: any, conn: Conn) {
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
            socket.to(sessId.toString()).emit("questionAnswered", answered);

            // if everyone has answered
            if (answered.count >= this.sess[sessId].countParticipants()) {
                this.releaseQuestionOutcome(socket, conn);
            }
        }

    }

    // WIP: release question outcome after timeout
    /**
     * Everyone has answered or timeout
     * @param socket 
     */
    releaseQuestionOutcome(socket: SocketIO.Socket, conn: Conn) {

        const sessId = conn.sessionToken.sessionId;;
        let questionOutCome = {};
        // WIP: summary question outcome here

        // braodcast question outcome
        socket.to(sessId.toString()).emit("questionOutcome", questionOutCome);
    }

    private welcomeMSG(quizId: number) {
        // WIP: format welcome message here

        return Array.from(this.sess[quizId].allParticipants());
    }

    async welcome(socket: SocketIO.Socket, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;
        const userId = conn.user.id;

        if (!this.isOwner(conn)) {
            // add user to socket room
            socket.join(sessId.toString());
            // add user to session
            const alreadyJoined = await this.sess[sessId].hasParticipant(userId);
            await this.sess[sessId].addParticipant(await this.getUserInfo(userId), socket);

            if (!alreadyJoined) {
                // broadcast that user has joined
                const msg = await this.getUserInfo(userId);
                socket.to(sessId.toString()).emit("playerJoin", msg);
            }

            socket.emit("welcome", this.welcomeMSG(sessId));

            if (this.sess[sessId].getQuizStatus() === QuizStatus.Starting) {
                socket.emit("starting", (this.sess[sessId].getQuizStartsAt() - Date.now()).toString());
            }
        }

    }

    async quit(socket: SocketIO.Socket, content: any, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;
        const userId = conn.sessionToken.userId;

        // remove this participants from session in memory
        await this.sess[sessId].removeParticipant(userId, socket);
        // leave from socket room
        socket.leave(sessId.toString());

        // WIP: Remove this participants from this quiz in DB records here

        // broadcast that user has left
        const msg = await this.getUserInfo(userId);
        socket.to(sessId.toString()).emit("playerLeave", msg);
        // disconnect
        socket.disconnect();
    }

    private isOwner(conn: Conn) {
        return conn.sessionToken.role === "owner";
    }


    start(socket: SocketIO.Socket, content: any, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;
        const userId = socket.handshake.query.userId;
        if (this.isOwner(conn)) {
            // WIP: make quiz status `starting` in session
            this.sess[sessId].setQuizStatus(QuizStatus.Starting);
            this.sess[sessId].setQuizStartsAt(Date.now() + WAITING);
            // Broadcast that quiz will be started
            socket.to(sessId.toString()).emit("starting", (this.sess[sessId].getQuizStartsAt() - Date.now()).toString());
            // pass-correct-this-context-to-settimeout-callback
            // https://stackoverflow.com/questions/2130241
            setTimeout(() => {
                this.sess[sessId].setQuizStatus(QuizStatus.Running);
                // release the firt question
                this.nextQuestion(socket, conn);
            }, this.sess[sessId].getQuizStartsAt() - Date.now(), socket);

        }
    }

    private cancelQuiz(quizId: number) {
        // WIP: disconnect all connections of this quiz
        console.log("disconnect all connections of quiz: " + quizId);
        this.sess[quizId].close();
    }

    abort(socket: SocketIO.Socket, content: any, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;
        const userId = socket.handshake.query.userId;
        if (this.isOwner(conn)) {
            // WIP: Deactivate this quiz in DB records here

            // Broadcast that quiz has been aborted
            socket.to(sessId.toString()).emit("cancelled", null);
            this.cancelQuiz(sessId);
        }

    }

    private formatQuestion(questionId: Object) {
        // format question to 
        // {
        //     "no": 1,
        //     "text": "Who sells the magic wands?",
        //     "hasPic": true | false
        //     "options": [
        //         {
        //             "text": "Aaron Harwood"
        //         },
        //         ...
        //     ],
        //     "time": 20
        // }

        const question = {
            "no": 1,
            "text": "Is Qifan Pretty?",
            "hasPic": true,
            "options": [
                {
                    "text": "YES"
                },
                {
                    "text": "SURE"
                }],
            "time": 20
        };
        return question;

    }

    nextQuestion(socket: SocketIO.Socket, conn: Conn) {
        const sessId = conn.sessionToken.sessionId;;
        const userId = socket.handshake.query.userId;

        if (this.isOwner(conn)) {
            //  broadcast next question to participants
            const nextQuestion = this.sess[sessId].nextQuestion();
            if (nextQuestion !== undefined) {
                const question = this.formatQuestion(nextQuestion);
                socket.to(sessId.toString()).emit("nextQuestion", question);
            }
        }
    }

    private formatBoard(quizId: number) {
        let leaderboard = [{ "this is leaderboard": "wohhoo" }];
        // WIP: format leaderborad here

        return leaderboard;
    }

    showBoard(socket: SocketIO.Socket, content: any, conn: Conn) {
        // NOTE: get quizId and userId from decrypted token
        // Record it somewhere (cache or socket.handshake)
        // * token will expire in 1 hour
        const sessId = conn.sessionToken.sessionId;;
        const userId = socket.handshake.query.userId;
        // get 
        const username = socket.handshake.query.name;

        if (this.isOwner(conn)) {
            //  broadcast Board to participants
            socket.to(sessId.toString()).emit("questionOutcome", this.formatBoard(sessId));
        }
    }

    async getUserInfo(userId: number): Promise<User> {
        if (userCache.hasOwnProperty(userId)) {
            return userCache[userId];
        } else {
            // TODO: get user info here
            let username = 'Handsome Broccoli - 1';
            let picId = 123;

            const user = new User(1, username, picId);
            userCache[userId] = user;
            return user;
        }
    }

}



