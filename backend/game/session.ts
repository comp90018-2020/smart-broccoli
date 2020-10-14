import { Session as SessInController, Quiz as QuizInModels } from "../models";
import { sessionTokenDecrypt as decrypt, SessionToken } from "../controllers/session"


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

export enum QuizStatus {
    Pending = 0,
    Starting = 1,
    Running = 2,
    Ended = 3
}

export class User {
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
    private id: number;
    SessInController: SessInController;
    status: QuizStatus;
    private quizStartsAt = 0;
    private participants: any;
    private participantsNames: { [key: string]: any };
    private questions: Question[];
    private questionsWithAns: Question[];
    private sockets: Set<SocketIO.Socket>;
    private questionIdx = 0;
    private preQuestionIdx = 0;
    private questionReleasedAt = 0;
    private questionPanel: {
        [key: string]: PlayerStatus
    };

    hasFinalBoardReleased: boolean;

    constructor($quiz: any, $s: SessInController) {
        this.id = $s.id;
        this.SessInController = $s;
        this.participants = new Set([]);
        this.participantsNames = {};
        this.sockets = new Set();
        this.questionPanel = {};
        this.status = QuizStatus.Pending;
        this.setQuestions($quiz);
        this.hasFinalBoardReleased = false;
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
        if(this.questionIdx === this.preQuestionIdx){
            const { no, text, pictureId, options, tf, time } = this.questions[this.questionIdx];
            return new Question(no, text, pictureId, options, tf, time * 1000 - (Date.now() - this.questionReleasedAt))
        }else{
            const { no, text, pictureId, options, tf, time } = this.questions[this.preQuestionIdx];
            return new Question(no, text, pictureId, options, tf, 0);
        }
    }

    getQuestion(idx: number) {
        return this.questions[idx];
    }

    getQuestionWithAns(idx: number) {
        return this.questionsWithAns[idx];
    }

    nextQuestionIdx(): number {
        if (this.questionIdx >= this.questions.length) { throw "no more question"; }
        else if (this.questions[this.questionIdx].time * 1000 +
            this.questionReleasedAt - Date.now() > 0) {
            throw "there is a running question";
        }
        else {
            this.resetQuestionPanel();
            this.questionReleasedAt = Date.now();
            setTimeout(() => {
                this.questionIdx++;
            }, this.questions[this.questionIdx].time * 1000);
            this.preQuestionIdx = this.questionIdx;
            return this.questionIdx;
        }
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

