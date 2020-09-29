import { jwtVerify } from "../helpers/jwt";
import Quiz from "../models/quiz";
import Question from "../models/question";
import {getQuiz} from "../controllers/quiz"; 

export class QuizIterator extends Quiz {
    private pos = 0;

    loadQuiz(quizId: number) {
    }

    next(){
        if (this.pos < this.questions.length)
            return this.questions[this.pos++];
        else
            return false;
    }

    [Symbol.iterator]() { return super.questions.values() }

}
export class LiveQuiz {
    // shaerd obj saves live quiz sess
    sess: {
        [key: number]: {
            [key: string]: any
        }
    };
    secret: string = "aaa";


    constructor() { 
        this.sess = {}
    }

    /**
     *  Verify socket connection using jwt token 
     * @param socket socket
     */
    verifySocketConn(socket: SocketIO.Socket) {
        // jwtVerify(socket.handshake.query.token, this.secret);
    }

    loadQuiz(quizId: number) {
        return {}
    }

    async activeQuiz(socket: SocketIO.Socket, content: any) {
        // verify connection
        this.verifySocketConn(socket);

        const quizId = content.quizId;
        const userId = socket.handshake.query.userId;
        console.log(userId)

        // json resoonse  
        let ret: { [key: string]: string };
        if (quizId in this.sess) {
            // quiz is in session
            if (this.sess[quizId].status == "inactive") {
                // and quiz is inactive
                this.sess[quizId].status = "active";
                ret = { "res": "success" }
            } else {
                ret = { "res": "failed", "msg": `Quiz ${quizId} is ${this.sess[quizId].status}` };
            }
        } else {
            // quiz is not in session
            // init quiz in session and make the status be active
            const quizJson = await getQuiz(userId, Number(quizId))
            console.log(this.sess);
            this.sess[quizId] = {"status":"active", "quiz": new Quiz()};
            ret = { "res": "success" }
        }

        // response to the end
        socket.send(ret);
    }

    abortQuiz(socket: SocketIO.Socket, content: any) {
        // verify connection
        this.verifySocketConn(socket);

        const quizId = content.quizId;

        // json resoonse  
        const ret = { "res": "success" };
        if (quizId in this.sess && "status" in this.sess[quizId]){
            this.sess[quizId].status = "active";
        }

        // response to the end
        socket.send(ret);

    }

    joinQuiz(socket: SocketIO.Socket, content: any) {
        // verify connection
        this.verifySocketConn(socket);

        const quizId = content.quizId;

        // json resoonse  
        let ret: { [key: string]: string };
        if (quizId in this.sess && this.sess[quizId].status === 'active') {
            // socket join in a room named ${quizId}
            socket.join(quizId);
            ret = { "res": "success" };
        } else {
            ret = { "res": "falied", "msg": `${quizId} is not active` };
        }

        console.log(this.sess)
        // response to the end
        socket.send(ret);

    }

    startQuiz(socket: SocketIO.Socket, content: any) {
        // verify connection
        this.verifySocketConn(socket);

        const quizId = content.quizId;

        if (quizId in this.sess && this.sess[quizId].status === 'active') {
            const msg = {"action": 0, "msg": "Quiz starts" };
            // broadcast to the room with msg that quiz has been started
            socket.to(quizId).send(msg);

            // broadcast to the room the first question
            this.nextQuestion(socket, content);
        } else {
            const ret = { "res": "falied", "msg": "`${quizId} is not active: `${this.sess[quizId].status}``" };
            socket.send(ret);
        }
    }

    nextQuestion(socket: SocketIO.Socket, content: any) {
        // verify connection
        this.verifySocketConn(socket);
        const quizId = content.quizId;
        // json resoonse  
        let ret: { [key: string]: any };

        if (quizId in this.sess && this.sess[quizId].status === 'active') {
            ret = {"action": 0, "msg": "Quiz starts" };
            // broadcast to the room that quiz has been started
            socket.to(quizId).send(ret);

            // broadcast to the room the first question
            this.nextQuestion(socket, content);
        } else {
            ret = { "res": "falied", "msg": "`${quizId} is not active: `${this.sess[quizId].status}``" };
            socket.send(ret);
        }
    }

    answerQuiz(socket: SocketIO.Socket, content: any) {

    }



    releaseLeaderBoardQuiz(socket: SocketIO.Socket, content: any) {

    }

    endQuiz(socket: SocketIO.Socket, content: any) {

    }

    getQuizStatus(socket: SocketIO.Socket, content: any) {

    }
}