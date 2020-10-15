import { Session as SessInController, Quiz as QuizInModels } from "../models";
import { sessionTokenDecrypt as decrypt, SessionToken } from "../controllers/session"
import { PointSystem, Answer, AnswerOutcome } from "./points";

export enum QuizStatus {
    Pending = 0,
    Starting = 1,
    Running = 2,
    Ended = 3
}

export class Player {
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
        readonly player: Player,
        readonly sessionToken: SessionToken
    ) { }
}

class Record {
    constructor(
        public oldPos: number,
        public newPos: number,
        public bonusPoints: number,
        public points: number,
        public streak: number
    ) { }
}

class PlayerRecord {
    constructor(readonly player: Player, readonly record: Record) { }
}

export class Session {
    private id: number;
    SessInController: SessInController;
    status: QuizStatus;
    private quizStartsAt = 0;
    private playerIdSet: Set<number>;
    private playerNames: { [key: string]: any };
    private players: { [key: string]: Player };
    public playerAnsOutcomes: { [key: string]: AnswerOutcome };
    private questions: Question[];
    private questionsWithAns: Question[];
    private sockets: Set<SocketIO.Socket>;
    private questionIdx = 0;
    private preQuestionIdx = 0;
    private questionReleasedAt = 0;
    public readyForNextQuestion: boolean = true;
    public pointSys: PointSystem = new PointSystem(0);
    public hasFinalBoardReleased: boolean;

    public playerRecords: { [key: number]: PlayerRecord };


    constructor($quiz: any, $s: SessInController) {
        this.id = $s.id;
        this.SessInController = $s;
        this.playerIdSet = new Set([]);
        this.playerNames = {};
        this.players = {};
        this.playerAnsOutcomes = {};
        this.sockets = new Set();
        this.status = QuizStatus.Pending;
        this.setQuestions($quiz);
        this.hasFinalBoardReleased = false;
        this.playerRecords = {};
    }

    async addParticipant(player: Player, socket: SocketIO.Socket) {
        this.playerIdSet.add(player.id);
        ++this.pointSys.participantCount;
        this.playerNames[player.id] = player.name;
        this.players[player.id] = player;
        this.sockets.add(socket);
        if (!this.playerAnsOutcomes.hasOwnProperty(player.id)) {
            this.playerAnsOutcomes[player.id] = new AnswerOutcome(false, 100000000, -1, -1);
        }

        if (!this.playerRecords.hasOwnProperty(player.id)) {
            const record = new Record(100000000, 100000000, 0, 0, -1);
            this.playerRecords[player.id] = new PlayerRecord(player, record);
        }
    }

    async removeParticipant(playerId: number, socket: SocketIO.Socket) {
        this.playerIdSet.delete(playerId);
        --this.pointSys.participantCount;
        delete this.playerNames[playerId];
        this.sockets.delete(socket);
    }

    async hasParticipant(playerId: number) {
        return this.playerIdSet.has(playerId);
    }

    countParticipants(): number {
        return this.playerIdSet.size;
    }

    allParticipants() {
        let participantsSet = new Set([]);
        for (const [key, value] of Object.entries(this.playerNames)) {
            participantsSet.add(value);
        }
        return participantsSet;
    }

    public hasPlayerAnswered(playerId: number) {
        return this.pointSys.answeredPlayer.has(playerId);
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


    getPreAnsOut(playerId: number) {
        return this.playerAnsOutcomes[playerId];
    }

    canAnswer(playerId: number) {
        return this.getActiveQuesionIdx() > this.playerAnsOutcomes[playerId].quesionNo;
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

    assessAns(playerId: number, ans: Answer) {
        const activeQuesionIdx = this.getActiveQuesionIdx();
        const correctAns = this.getAnsOfQuestion(activeQuesionIdx);
        const preAnsOut = this.getPreAnsOut(playerId);
        const ansOutcome: AnswerOutcome = this.pointSys.checkAns(ans, correctAns, preAnsOut);
        // record in session that player has answered
        this.playerAnsOutcomes[playerId] = ansOutcome;
        this.pointSys.answeredPlayer.add(playerId);
        const points = this.pointSys.getNewPoints(ansOutcome);
        this.updateBoard(playerId, points, ansOutcome);
    }

    trySettingForNewQuesiton(): boolean {
        if (this.pointSys.hasAllPlayersAnswered()) {
            this.questionIdx = this.preQuestionIdx + 1;
            this.pointSys.setForNewQuestion();
            this.readyForNextQuestion = true;
            return true;
        } else {
            return false;
        }
    }

    async updateBoard(playerId: number, points: number, ansOutCome: AnswerOutcome) {
        this.playerRecords[playerId].record.oldPos = this.playerRecords[playerId].record.newPos;
        this.playerRecords[playerId].record.newPos = null;
        this.playerRecords[playerId].record.bonusPoints = points;
        this.playerRecords[playerId].record.points = points + this.playerRecords[playerId].record.points;
        this.playerRecords[playerId].record.streak = ansOutCome.streak;

        console.log(this.playerRecords);
    }

    rankBoard(){
        const playerRecordsList : PlayerRecord[] = [];
        for(const [playerId, playerRecord]  of Object.entries(this.playerRecords)){
            playerRecordsList.push(playerRecord);
        }
        // list.sort((a, b) => (a.color > b.color) ? 1 : -1)
        // https://flaviocopes.com/how-to-sort-array-of-objects-by-property-javascript/
        playerRecordsList.sort((a, b) => (a.record.points < b.record.points) ? 1 : -1);

        console.log("palyer records list length: ", playerRecordsList.length);

        for (let [i, playerRecord] of playerRecordsList.entries()) {
            console.log(i);
            playerRecord.record.newPos = i;
            console.log(playerRecord);
            this.playerRecords[playerRecord.player.id] = playerRecord;
        }

        console.log(this.playerRecords);

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
        this.playerIdSet = new Set();
    }

}

