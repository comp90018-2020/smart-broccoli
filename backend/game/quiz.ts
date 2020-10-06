import { jwtVerify } from "../helpers/jwt";

export class Session {
    private participants: any;
    private questions: [number];
    private sockets: any;
    private questionIdx = 0;

    constructor() {
        this.participants = new Set([]);
        this.sockets = new Set();
    }

    addParticipant(userId: string, socket: SocketIO.Socket): void {
        this.participants.add(userId);
        this.sockets.add(socket);
    }

    removeParticipant(userId: string, socket: SocketIO.Socket): void {
        this.participants.delete(userId);
        this.sockets.delete(socket);
    }

    hasParticipant(userId: string): boolean {
        return this.participants.has(userId);
    }

    countParticipants():number{
        return this.participants.length;
    }

    allParticipants(){
        return this.participants;
    }
    
    /**
     * Set questions list of this session
     * @param questions questions list
     */
    setQuestions(questions: any) {
        this.questions = questions;
    }

    nextQuestion(): Object {
        if (this.questionIdx < this.questions.length) {
            return this.questions[this.questionIdx++];
        } else {
            return undefined;
        }
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
        [key: string]: Session
    };

    constructor() {
        this.sess= {};
        // DEBUG ===>
        let s = new Session();
        s.setQuestions([0]);
        this.addSession('1', s);
        // DEBUG <===
    }

    addSession(quizId: string, session: Session) {
        this.sess[quizId] = session;
    }

    /**
     *  Verify socket connection using jwt token 
     * @param socket socket
     */
    verifySocketConn(socket: SocketIO.Socket) {
        // WIP: verify connection
        // jwtVerify(socket.handshake.query.token, this.secret);
        return true;
    }


    private checkAnswer(quizId: string, answer: any) {
        const questionId = answer.question;
        const MCSelection = answer.MCSelection;
        const TFSelection = answer.TFSelection;
        const points = 0;
        // check answers for this question here 
        return points;
    }

    private recordPoints(userId: string, points: number) {
        // WIP: record points gained
    }


    private formatAnswered(quizId: string, questionId: string) {
        let count = 0;
        // WIP: get answered paticipant count here

        return {
            "question": questionId,
            "count": count
        }

    }

    answer(socket: SocketIO.Socket, content: any) {
        // {
        //     "question": 3,
        //     "MCSelection": 0,  // list index of answer chosen (for MC Question)
        //     "TFSelection": true | false  // for TF question
        // }
        const quizId = socket.handshake.query.quizId;
        const userId = socket.handshake.query.userId;
        const questionId = content.questionId;
        console.log([quizId, userId, questionId])

        const points = this.checkAnswer(quizId, content);
        this.recordPoints(userId, points);

        // braodcast that one more participants answered this question
        const answered = this.formatAnswered(quizId, questionId);

        console.log(answered);
        socket.to(quizId).emit("questionAnswered", answered);

        // if everyone has answered
        if (answered.count >= this.sess[quizId].countParticipants()) {
            this.releaseQuestionOutcome(socket);
        }
    }

    // WIP: release question outcome after timeout
    /**
     * Everyone has answered or timeout
     * @param socket 
     */
    releaseQuestionOutcome(socket: SocketIO.Socket) {

        const quizId = socket.handshake.query.quizId;
        let questionOutCome = {};
        // WIP: summary question outcome here

        // braodcast question outcome
        socket.to(quizId).emit("questionOutcome", questionOutCome);
    }

    private welcomeMSG(quizId: string) {
        // WIP: format welcome message here

        return Array.from(this.sess[quizId].allParticipants());
    }

    welcome(socket: SocketIO.Socket) {
        const quizId = socket.handshake.query.quizId;
        const userId = socket.handshake.query.userId;

        if (!this.isOwner(quizId, userId)) {
            // add user to socket room
            socket.join(quizId);
            // add user to session
            const alreadyJoined = this.sess[quizId].hasParticipant(userId);
            this.sess[quizId].addParticipant(userId, socket);

            // broadcast that user has joined
            const msg =
            {
                "id": userId,
                "name": this.getUserNameById(userId)
            }

            if (!alreadyJoined) {
                socket.to(quizId).emit("playerJoin", msg);
            }

            socket.emit("welcome", this.welcomeMSG(quizId));
        }

    }

    quit(socket: SocketIO.Socket, content: any) {
        const quizId = socket.handshake.query.quizId;
        const userId = socket.handshake.query.userId;

        // remove this participants from session in memory
        this.sess[quizId].removeParticipant(userId, socket);
        // leave from socket room
        socket.leave(quizId);

        // WIP: Remove this participants from this quiz in DB records here

        // broadcast that user has left
        const msg =
        {
            "id": userId,
            "name": this.getUserNameById(userId)
        }
        socket.to(quizId).emit("playerLeave", msg);
        // disconnect
        socket.disconnect();
    }

    private isOwner(quizId: string, userId: string) {
        let ret = true;
        // WIP: check if the user owns this quiz here
        if (userId == '1') {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }

    private starting(quizId: string) {
        // quiz will be started in 10 seconds
        return "10";
    }

    start(socket: SocketIO.Socket, content: any) {
        console.log(socket.handshake.query);
        const quizId = socket.handshake.query.quizId;
        const userId = socket.handshake.query.userId;
        console.log(socket.handshake.query.quizId);
        console.log(socket.handshake.query.userId);
        if (this.isOwner(quizId, userId)) {
            // WIP: make quiz status started in session
            console.log(this.sess)

            // Broadcast that quiz will be started
            socket.to(quizId).emit("starting", this.starting(quizId));
        }

    }

    private cancelQuiz(quizId: string) {
        // WIP: disconnect all connections of this quiz
        console.log("disconnect all connections of quiz: " + quizId);
        this.sess[quizId].close();
    }

    abort(socket: SocketIO.Socket, content: any) {
        const quizId = socket.handshake.query.quizId;
        const userId = socket.handshake.query.userId;
        console.log([quizId, userId]);
        if (this.isOwner(quizId, userId)) {
            // WIP: Deactivate this quiz in DB records here

            // Broadcast that quiz has been aborted
            socket.to(quizId).emit("cancelled", null);
            this.cancelQuiz(quizId);
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

    nextQuestion(socket: SocketIO.Socket, content: any) {
        const quizId = socket.handshake.query.quizId;
        const userId = socket.handshake.query.userId;
        
        if (this.isOwner(quizId, userId)) {
            //  broadcast next question to participants
            const nextQuestion = this.sess[quizId].nextQuestion();
            if (nextQuestion !== undefined) {
                const question = this.formatQuestion(nextQuestion);
                socket.to(quizId).emit("nextQuestion", question);
            }
        }
    }

    private formatBoard(quizId: string) {
        let leaderboard = [{ "this is leaderboard": "wohhoo" }];
        // WIP: format leaderborad here

        return leaderboard;
    }

    showBoard(socket: SocketIO.Socket, content: any) {
        const quizId = socket.handshake.query.quizId;
        const userId = socket.handshake.query.userId;

        if (this.isOwner(quizId, userId)) {
            //  broadcast Board to participants
            socket.to(quizId).emit("questionOutcome", this.formatBoard(quizId));
        }
    }

    private getUserNameById(userId: string) {
        return "Handsome Broccoli - " + userId;
    }
}
