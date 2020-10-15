import { Session as SessInController, Quiz as QuizInModels } from "../models";
import { sessionTokenDecrypt as decrypt, SessionToken } from "../controllers/session"
import { PointSystem, Answer, AnswerOutcome } from "./scores";

enum AnswerStatus {
    NoAnswered = 0,
    Answered = 1
}

enum GameStatus {
    InGame = 0,
    Left = 1
}

class PlayerStatus {
    constructor(
        public answer: AnswerStatus,
        public game: GameStatus
    ) { };
}

export enum QuizStatus {
    Pending = 0,
    Starting = 1,
    Running = 2,
    Ended = 3
}

export class User {
    constructor(
        readonly id: number,
        readonly name: string,
        readonly picturId: number
    ) { };
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
    private id: number;
    SessInController: SessInController;
    status: QuizStatus;
    private quizStartsAt = 0;
    private participants: any;
    private participantNames: { [key: string]: any };
    public participantAnsOutcomes: { [key: string]: AnswerOutcome };
    private questions: Question[];
    private questionsWithAns: Question[];
    private sockets: Set<SocketIO.Socket>;
    private questionIdx = 0;
    private preQuestionIdx = 0;
    private questionReleasedAt = 0;
    public readyForNextQuestion : boolean = true;
    public pointSys: PointSystem = new PointSystem(0);
    public hasFinalBoardReleased: boolean;

    constructor($quiz: any, $s: SessInController) {
        this.id = $s.id;
        this.SessInController = $s;
        this.participants = new Set([]);
        this.participantNames = {};
        this.participantAnsOutcomes = {};
        this.sockets = new Set();
        this.status = QuizStatus.Pending;
        this.setQuestions($quiz);
        this.hasFinalBoardReleased = false;
    }

    async addParticipant(user: User, socket: SocketIO.Socket) {
        this.participants.add(user.id);
        ++this.pointSys.participantCount;
        this.participantNames[user.id] = user.name;
        this.sockets.add(socket);
        if (!this.participantAnsOutcomes.hasOwnProperty(user.id)) {
            this.participantAnsOutcomes[user.id] = new AnswerOutcome(false, 100000000, -1, -1);
        }
    }

    async removeParticipant(userId: number, socket: SocketIO.Socket) {
        this.participants.delete(userId);
        --this.pointSys.participantCount;
        delete this.participantNames[userId];
        this.sockets.delete(socket);
    }

    async hasParticipant(userId: number) {
        return this.participants.has(userId);
    }

    countParticipants(): number {
        return this.participants.size;
    }

    allParticipants() {
        let participantsSet = new Set([]);
        for (const [key, value] of Object.entries(this.participantNames)) {
            participantsSet.add(value);
        }
        return participantsSet;
    }

    public playerAnswered(userId: number, ansOutcome: AnswerOutcome, points: number) {
        // TODO
    }

    public hasPlayerAnswered(userId: number) {
        // TODO
        return this.pointSys.answeredPlayer.has(userId);
    }

    /**
     * Set questions list of this session
     * @param questions questions list
     */
    private async setQuestions(quiz: any) {
        // TODO: format questions that can be sent to players here
        const questions: Question[] = [];
        const questionsWithAns: Question[] = [];
        let i = 0;
        while (quiz.questions.length > 0) {
            const q = quiz.questions.shift();
            const options: Option[] = q.options === null ? null : [];
            const optionsWithAns: Option[] = q.options === null ? null : [];

            if (options !== null) {
                while (q.options.length > 0) {
                    const option = q.options.shift();
                    options.push(new Option(null, option.text))
                    optionsWithAns.push(new Option(option.correct, option.text))
                }
            }
            const question = new Question(
                i,
                q.text,
                q.pictureId,
                options,
                null,
                quiz.timeLimit);
            const questionWithAns = new Question(
                i,
                q.text,
                q.pictureId,
                optionsWithAns,
                q.tf,
                quiz.timeLimit);

            i++;
            questions.push(question);
            questionsWithAns.push(questionWithAns);
        }
        this.questions = questions;
        this.questionsWithAns = questionsWithAns;
    }

    /**
     * If a connection is lost and subsequently restored during a quiz, 
     * send current question immediately (corresponding to the current question; 
     * update time field).
     */
    currQuestion() {
        if (this.questionIdx === this.preQuestionIdx) {
            const { no, text, pictureId, options, tf, time } = this.questions[this.questionIdx];
            return new Question(no, text, pictureId, options, tf, time * 1000 - (Date.now() - this.questionReleasedAt))
        } else {
            const { no, text, pictureId, options, tf, time } = this.questions[this.preQuestionIdx];
            return new Question(no, text, pictureId, options, tf, 0);
        }
    }

    getQuestion(idx: number): Question {
        return this.questions[idx];
    }

    getQuestionWithAns(idx: number): Question {
        return this.questionsWithAns[idx];
    }

    isCurrQuestionActive() {
        return this.preQuestionIdx === this.questionIdx;
    }

    getAnsOfQuestion(idx: number): Answer {
        const questionWithAns = this.getQuestionWithAns(idx);
        if (questionWithAns.options === null) {
            return new Answer(questionWithAns.no, null, questionWithAns.tf);
        } else {
            let i = 0
            for (const option of questionWithAns.options) {
                if (option.correct) {
                    return new Answer(questionWithAns.no, i, null);
                }
                ++i;
            }
            throw `No ans in Question[${idx}], this should never happen.`
        }
    }

    getActiveQuesionIdx(): number {
        return this.preQuestionIdx;
    }


    getPreAnsOut(userId: number) {
        return this.participantAnsOutcomes[userId];
    }

    canAnswer(userId: number) {
        return this.getActiveQuesionIdx() > this.participantAnsOutcomes[userId].quesionNo;
    }

    nextQuestionIdx(): number {
        if (this.questionIdx >= this.questions.length) { throw "no more question"; }
        else if (this.questions[this.questionIdx].time * 1000 +
            this.questionReleasedAt - Date.now() > 0 && !this.readyForNextQuestion) {
            throw "there is a running question";
        }
        else {
            this.questionReleasedAt = Date.now();
            setTimeout(() => {
                if (this.questionIdx === this.preQuestionIdx) {
                    this.questionIdx = this.preQuestionIdx + 1;
                    this.pointSys.setForNewQuestion();
                }
            }, this.questions[this.questionIdx].time * 1000);
            this.preQuestionIdx = this.questionIdx;
            this.readyForNextQuestion = false;
            return this.questionIdx;
        }
    }

    assessAns(userId: number, ans: Answer) {
        const activeQuesionIdx = this.getActiveQuesionIdx();
        const correctAns = this.getAnsOfQuestion(activeQuesionIdx);
        const preAnsOut = this.getPreAnsOut(userId);
        const ansOutcome = this.pointSys.checkAns(ans, correctAns, preAnsOut);
        // record in session that player has answered
        this.participantAnsOutcomes[userId] = ansOutcome;
        this.pointSys.answeredPlayer.add(userId);

        const points = this.pointSys.getNewPoints(ansOutcome);
        this.updateBoard(userId, points, ansOutcome);
    }

    setForNewQuesiton():boolean{
        if(this.pointSys.hasAllPlayersAnswered()){
            this.questionIdx = this.preQuestionIdx + 1;
            this.pointSys.setForNewQuestion();
            this.readyForNextQuestion = true;
            return true;
        }else{
            return false;
        }
    }

    updateBoard(userId: number, points: number, ansOutCome: AnswerOutcome) {
        console.log(userId, points, ansOutCome);
    }

    setQuizStatus(status: QuizStatus) {
        this.status = status;
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

