import { SessionToken } from "../controllers/session";
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
        readonly sessionId: number,
        readonly questionFinshed: number,
        readonly questionTotal: number,
        readonly board: PlayerRecord[]
    ) {}
}

export class Player {
    constructor(
        readonly id: number,
        readonly name: string,
        readonly pictureId: number
    ) {}
}

export class PlayerSession {
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
    private sessionId: number;
    public quiz: any;
    public status: QuizStatus = QuizStatus.Pending;
    private quizStartsAt = 0;
    private playerIdSet: Set<number> = new Set([]);
    private players: { [key: string]: Player } = {};
    public playerAnsOutcomes: { [key: string]: AnswerOutcome } = {};
    private sockets: { [key: number]: Socket } = {};
    private questionIdx = 0;
    private preQuestionIdx = 0;
    private questionReleasedAt = 0;
    public readyForNextQuestion: boolean = true;
    public pointSys: PointSystem = new PointSystem(0);
    public hasFinalBoardReleased: boolean = false;

    public playerRecords: { [key: number]: PlayerRecord } = {};
    public playerRecordList: PlayerRecord[] = [];
    public result: QuizResult = null;

    constructor($quiz: any, $sessionId: number) {
        this.sessionId = $sessionId;
        this.quiz = $quiz;
    }

    async addParticipant(player: Player, socket: Socket) {
        this.playerIdSet.add(player.id);
        ++this.pointSys.participantCount;
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
        for (const [key, player] of Object.entries(this.players)) {
            participantsSet.add(player);
        }
        return participantsSet;
    }

    public hasPlayerAnswered(playerId: number) {
        return this.pointSys.answeredPlayer.has(playerId);
    }

    /**
     * If a connection is lost and subsequently restored during a quiz,
     * send current question immediately (corresponding to the current question;
     * update time field).
     */
    currQuestion() {
        if (this.questionIdx === this.preQuestionIdx) {
            const {
                no,
                text,
                pictureId,
                options,
                tf,
                time,
            } = this.quiz.questions[this.questionIdx];
            return {
                id: no,
                text: text,
                tf: tf,
                options: options,
                pictureId: pictureId,
                time: time * 1000 - (Date.now() - this.questionReleasedAt),
            };
        } else {
            const {
                no,
                text,
                pictureId,
                options,
                tf,
                time,
            } = this.quiz.questions[this.preQuestionIdx];
            return {
                id: no,
                text: text,
                tf: tf,
                options: options,
                pictureId: pictureId,
                time: 0,
            };
        }
    }

    getQuestion(idx: number) {
        return this.quiz[idx];
    }

    isCurrQuestionActive() {
        return this.preQuestionIdx === this.questionIdx;
    }

    getAnsOfQuestion(idx: number): Answer {
        const questionWithAns = this.quiz.questions[idx];

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
            this.playerAnsOutcomes[playerId].questionNo
        );
    }

    nextQuestionIdx(): number {
        if (this.questionIdx >= this.quiz.questions.length) {
            throw "no more question";
        } else if (!this.readyForNextQuestion) {
            throw "there is a running question";
        } else {
            this.questionReleasedAt = Date.now();
            setTimeout(() => {
                if (this.questionIdx === this.preQuestionIdx) {
                    this.moveToNextQuestion();
                }
            }, this.quiz.questions[this.questionIdx].time * 1000);
            this.preQuestionIdx = this.questionIdx;
            this.readyForNextQuestion = false;
            return this.questionIdx;
        }
    }

    assessAns(playerId: number, ans: Answer) {
        const activeQuesionIdx = this.getActiveQuesionIdx();
        const correctAns = this.getAnsOfQuestion(activeQuesionIdx);
        const preAnsOut = this.getPreAnsOut(playerId);
        const ansOutcome: AnswerOutcome = this.checkAns(
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

    checkAns(
        ans: Answer,
        correctAns: Answer,
        preAnsOutcome: AnswerOutcome
    ): AnswerOutcome {
        if (ans.questionNo !== correctAns.questionNo) {
            throw `This is ans for question ${ans.questionNo} not for ${correctAns.questionNo}`;
        } else {
            const correct =
                correctAns.MCSelection !== null
                    ? ans.MCSelection === correctAns.MCSelection
                        ? true
                        : false
                    : ans.TFSelection === correctAns.TFSelection
                    ? true
                    : false;

            if (correct) {
                return new AnswerOutcome(
                    correct,
                    this.pointSys.getRankForARightAns(),
                    preAnsOutcome.streak + 1,
                    correctAns.questionNo
                );
            } else {
                return new AnswerOutcome(
                    correct,
                    this.pointSys.participantCount,
                    0,
                    correctAns.questionNo
                );
            }
        }
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
        this.result = new QuizResult(
            this.sessionId,
            (this.questionIdx === 0 && this.readyForNextQuestion
                ? -1
                : this.readyForNextQuestion
                ? this.preQuestionIdx
                : this.preQuestionIdx - 1) + 1,
            this.quiz.questions.length,
            this.playerRecordList
        );
    }
}
