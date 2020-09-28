import { ContextHandlerImpl } from "express-validator/src/chain";
import { jwtVerify } from "../helpers/jwt";
class Quiz{
    quiz : {[key:number] : any};
    pos = -1;
    constructor(quizId: number){
    }
    loadQuiz(quizId : number){
        this.quiz[1] = {};
    }
    next(){
        return this.quiz[this.pos++];
    }
    

}
class LiveQuiz {
    // shaerd obj saves live quiz sess
    sess: {
        [key: number]: {
            [key: string]: any
        }
    };
    secret: string = "aaa";


    constructor() { }

    /**
     *  Verify socket connection using jwt token 
     * @param socket socket
     */
    verifySocketConn(socket: SocketIO.Socket) {
        // jwtVerify(socket.handshake.query.token, this.secret);
    }

    loadQuiz(quizId: number){
        return {}
    }

    activeQuiz(socket: SocketIO.Socket, content: any) {
        // verify connection
        this.verifySocketConn(socket);

        const quizId = content.quizId;

        // json resoonse  
        let ret: { [key: string]: string };
        console.log(content);
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
            this.sess[quizId].status = "active";
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
        this.sess[quizId].status = "active";

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
        } else{
            ret = { "res": "falied", "msg":"`${quizId} is not active: `${this.sess[quizId].status}``" };
        }

        // response to the end
        socket.send(ret);

    }

    startQuiz(socket: SocketIO.Socket, content: any) {
        // verify connection
        this.verifySocketConn(socket);

        const quizId = content.quizId;

        // json resoonse  
        let ret: { [key: string]: string };
        if (quizId in this.sess && this.sess[quizId].status === 'active') {
            ret = { "res": "success" };
            // broadcast to the room that quiz has been started
            socket.to(quizId).send(ret);
            
            // broadcast to the room the first question
            this.nextQuestion(socket, content);
        } else{
            ret = { "res": "falied", "msg":"`${quizId} is not active: `${this.sess[quizId].status}``" };
            socket.send(ret);
        }
    }

    answerQuiz(socket: SocketIO.Socket, content: any) {

    }

    nextQuestion(socket: SocketIO.Socket, content: any) {

    }

    getLeaderBoardQuiz(socket: SocketIO.Socket) {

    }

    endQuiz(socket: SocketIO.Socket) {

    }
}

export { LiveQuiz };