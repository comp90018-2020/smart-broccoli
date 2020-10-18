import {
    Session as SessInController,
} from "../models";
import {
    SessionToken,
} from "../controllers/session";
import { PointSystem, Answer, AnswerOutcome } from "./points";
import { Socket } from "socket.io";

export enum QuizStatus {
    Pending = 0,
    Starting = 1,
    Running = 2,
    Ended = 3,
}

export class QuizResult {
    constructor(
        readonly questionFinshed: number,
        readonly questionTotal: number,
        readonly borad: PlayerRecord[]
    ) {}
}

export class Player {
    constructor(
        readonly id: number,
        readonly name: string,
        readonly picturId: number
    ) {}
}

class Option {
    constructor(readonly correct: boolean, readonly text: string) {}
}

class Question {
    constructor(
        readonly no: number,
        readonly text: string,
        readonly pictureId: boolean,
        readonly options: Option[] | null,
        readonly tf: boolean | null,
        readonly time: number
    ) {}
}

export class Conn {
    constructor(readonly player: Player, readonly sessionToken: SessionToken) {}
}

class Record {
    constructor(
        public oldPos: number,
        public newPos: number,
        public bonusPoints: number,
        public points: number,
        public streak: number
    ) {}
}

export class PlayerRecord {
    constructor(readonly player: Player, readonly record: Record) {}
}

export class Session {
    private id: number;
    public sessInController: SessInController;
    public status: QuizStatus = QuizStatus.Pending;
    private quizStartsAt = 0;
    private playerIdSet: Set<number> = new Set([]);
    private playerNames: { [key: string]: any } = {};
    private players: { [key: string]: Player } = {};
    public playerAnsOutcomes: { [key: string]: AnswerOutcome } = {};
    private questions: Question[];
    private questionsWithAns: Question[];
    private sockets: { [key: number]: Socket } = {};
    private questionIdx = 0;
    private preQuestionIdx = 0;
    private questionReleasedAt = 0;
    public readyForNextQuestion: boolean = true;
    public pointSys: PointSystem = new PointSystem(0);
    public hasFinalBoardReleased: boolean = false;

    public playerRecords: { [key: number]: PlayerRecord } = {};
    public playerRecordList: PlayerRecord[] = [];
    public result: [SessInController, QuizResult] = null;

    constructor($quiz: any, $s: SessInController) {
        this.id = $s.id;
        this.sessInController = $s;
        this.setQuestions($quiz);
    }

    async addParticipant(player: Player, socket: Socket) {
        this.playerIdSet.add(player.id);
        ++this.pointSys.participantCount;
        this.playerNames[player.id] = player.name;
        this.players[player.id] = player;
        this.sockets[player.id] = socket;
        if (!this.playerAnsOutcomes.hasOwnProperty(player.id)) {
            this.playerAnsOutcomes[player.id] = new AnswerOutcome(
                false,
                null,
                -1,
                -1
            );
        }

        if (!this.playerRecords.hasOwnProperty(player.id)) {
            const record = new Record(null, null, 0, 0, -1);
            this.playerRecords[player.id] = new PlayerRecord(player, record);
        }
    }

    async removeParticipant(playerId: number, socket: Socket) {
        this.playerIdSet.delete(playerId);
        --this.pointSys.participantCount;
        delete this.playerNames[playerId];
        delete this.sockets[playerId];
    }

    async hasParticipant(playerId: number) {
        return this.playerIdSet.has(playerId);
    }

    countParticipants(): number {
        return this.playerIdSet.size;
    }

    allParticipants() {
        const participantsSet = new Set([]);
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
                    options.push(new Option(null, option.text));
                    optionsWithAns.push(
                        new Option(option.correct, option.text)
                    );
                }
            }
            const question = new Question(
                i,
                q.text,
                q.pictureId,
                options,
                null,
                quiz.timeLimit
            );
            const questionWithAns = new Question(
                i,
                q.text,
                q.pictureId,
                optionsWithAns,
                q.tf,
                quiz.timeLimit
            );

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
            const { no, text, pictureId, options, tf, time } = this.questions[
                this.questionIdx
            ];
            return new Question(
                no,
                text,
                pictureId,
                options,
                tf,
                time * 1000 - (Date.now() - this.questionReleasedAt)
            );
        } else {
            const { no, text, pictureId, options, tf, time } = this.questions[
                this.preQuestionIdx
            ];
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
            let i = 0;
            for (const option of questionWithAns.options) {
                if (option.correct) {
                    return new Answer(questionWithAns.no, i, null);
                }
                ++i;
            }
            throw `No ans in Question[${idx}], this should never happen.`;
        }
    }

    getActiveQuesionIdx(): number {
        return this.preQuestionIdx;
    }

    getPreAnsOut(playerId: number) {
        return this.playerAnsOutcomes[playerId];
    }

    canAnswer(playerId: number) {
        return (
            this.getActiveQuesionIdx() >
            this.playerAnsOutcomes[playerId].quesionNo
        );
    }

    nextQuestionIdx(): number {
        if (this.questionIdx >= this.questions.length) {
            throw "no more question";
        } else if (!this.readyForNextQuestion) {
            throw "there is a running question";
        } else {
            this.questionReleasedAt = Date.now();
            setTimeout(() => {
                if (this.questionIdx === this.preQuestionIdx) {
                    this.moveToNextQuestion();
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
        const ansOutcome: AnswerOutcome = this.pointSys.checkAns(
            ans,
            correctAns,
            preAnsOut
        );
        // record in session that player has answered
        this.playerAnsOutcomes[playerId] = ansOutcome;
        this.pointSys.answeredPlayer.add(playerId);
        const points = this.pointSys.getNewPoints(ansOutcome);
        this.updateBoard(playerId, points, ansOutcome);
    }

    trySettingForNewQuesiton(): boolean {
        if (this.pointSys.hasAllPlayersAnswered()) {
            this.moveToNextQuestion();
            return true;
        } else {
            return false;
        }
    }

    private moveToNextQuestion() {
        this.questionIdx = this.preQuestionIdx + 1;
        this.pointSys.setForNewQuestion();
        this.readyForNextQuestion = true;
    }

    async updateBoard(
        playerId: number,
        points: number,
        ansOutCome: AnswerOutcome
    ) {
        this.playerRecords[playerId].record.oldPos = this.playerRecords[
            playerId
        ].record.newPos;
        this.playerRecords[playerId].record.newPos = null;
        this.playerRecords[playerId].record.bonusPoints = points;
        this.playerRecords[playerId].record.points =
            points + this.playerRecords[playerId].record.points;
        this.playerRecords[playerId].record.streak = ansOutCome.streak;
    }

    rankBoard() {
        const playerRecordsList: PlayerRecord[] = [];
        for (const [playerId, playerRecord] of Object.entries(
            this.playerRecords
        )) {
            playerRecordsList.push(playerRecord);
        }
        // https://flaviocopes.com/how-to-sort-array-of-objects-by-property-javascript/
        playerRecordsList.sort((a, b) =>
            a.record.points < b.record.points ? 1 : -1
        );
        this.playerRecordList = playerRecordsList;
        for (const [i, playerRecord] of playerRecordsList.entries()) {
            playerRecord.record.newPos = i;
            this.playerRecords[playerRecord.player.id] = playerRecord;
        }
    }

    releaseBoard(hostSocket: Socket) {
        for (const [playerId, socket] of Object.entries(this.sockets)) {
            const playerRecord = this.playerRecords[Number(playerId)];
            const playerAheadRecord =
                playerRecord.record.newPos === 0
                    ? null
                    : this.playerRecordList[playerRecord.record.newPos - 1];
            const quesitonOutcome = {
                question: this.preQuestionIdx,
                leaderBoard: this.playerRecordList.slice(0, 5),
                record: this.playerRecords[Number(playerId)].record,
                playerAhead: playerAheadRecord,
            };
            socket.emit("questionOutcome", quesitonOutcome);
        }
        hostSocket.emit("questionOutcome", {
            question: this.preQuestionIdx,
            leaderboard: this.playerRecordList,
        });
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
        for (const [playerId, socket] of Object.entries(this.sockets)) {
            socket.disconnect();
        }
        this.result = [
            this.sessInController,
            new QuizResult(
                (this.questionIdx === 0 && this.readyForNextQuestion
                    ? -1
                    : this.readyForNextQuestion
                    ? this.preQuestionIdx
                    : this.preQuestionIdx - 1) + 1,
                this.questions.length,
                this.playerRecordList
            ),
        ];
        console.log(this.result);
    }
}
