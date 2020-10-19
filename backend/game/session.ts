import { TokenInfo as TokenInfo } from "../controllers/session";
import { PointSystem, Answer, AnswerOutcome } from "./points";
import { Socket, Server } from "socket.io";
import {rankPlayer} from "./formatter"

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
        readonly board: Player[]
    ) { }
}

export class Player {
    public record: { [key: string]: any } = {};
    constructor(
        readonly id: number,
        readonly name: string,
        readonly pictureId: number,
        public socketId:string,
        public sessionId:number,
        public role: string
    ) {
        this.record.oldPos = null;
        this.record.newPos = null;
        this.record.bonusPoints = 0;
        this.record.points = 0;
        this.record.streak = -1;
    }
}


export class GameSession {
    private sessionId: number;
    public quiz: any;
    public status: QuizStatus = QuizStatus.Pending;
    private playerMap: { [playerId: number]: Player } = {};
    public playerAnsOutcomes: { [key: string]: AnswerOutcome } = {};
    private questionIdx = 0;
    private preQuestionIdx = 0;
    private quizStartsAt = 0;
    private questionReleasedAt = 0;
    public readyForNextQuestion: boolean = true;
    public pointSys: PointSystem = new PointSystem(0);
    public hasFinalBoardReleased: boolean = false;
    public result: QuizResult = null;

    constructor($quiz: any, $sessionId: number) {
        this.sessionId = $sessionId;
        this.quiz = $quiz;
    }

    async addParticipant(player: Player, socket: Socket) {
        if (!this.playerMap.hasOwnProperty(player.id)) {
            ++this.pointSys.participantCount;
            this.playerMap[player.id] = player;
            if (!this.playerAnsOutcomes.hasOwnProperty(player.id)) {
                this.playerAnsOutcomes[player.id] = new AnswerOutcome(
                    false,
                    null,
                    -1,
                    -1
                );
            }
        }

    }

    async removeParticipant(playerId: number, socket: Socket) {
        delete this.playerMap[playerId];
        --this.pointSys.participantCount;
    }

    async hasParticipant(playerId: number) {
        return this.playerMap.hasOwnProperty(playerId);
    }

    countParticipants(): number {
        return Object.keys(this.playerMap).length;
    }

    allParticipants() {
        const participantsSet = new Set([]);
        for (const [key, player] of Object.entries(this.playerMap)) {
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
        console.log(ansOutcome);
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
        this.playerMap[playerId].record.oldPos = this.playerMap[
            playerId
        ].record.newPos;
        this.playerMap[playerId].record.newPos = null;
        this.playerMap[playerId].record.bonusPoints = points;
        this.playerMap[playerId].record.points =
            points + this.playerMap[playerId].record.points;
        this.playerMap[playerId].record.streak = ansOutCome.streak;
        console.log(this.playerMap);
    }
;
    releaseBoard(socketIO:Server, hostSocket: Socket) {
        const playersArray =  rankPlayer(this.playerMap);
        // socketIO.sockets.adapter.rooms[this.sessionId].sockets)
        for (const [playerId, player] of Object.entries(this.playerMap)) {
            const playerRecord = this.playerMap[Number(playerId)];
            const playerAheadRecord =
                playerRecord.record.newPos === 0
                    ? null
                    : playersArray[playerRecord.record.newPos - 1];
            const quesitonOutcome = {
                question: this.preQuestionIdx,
                leaderBoard: playersArray.slice(0, 5),
                record: playersArray[Number(playerId)].record,
                playerAhead: playerAheadRecord,
            };
            socketIO.to(player.socketId).emit("questionOutcome", quesitonOutcome);
        }
        hostSocket.emit("questionOutcome", {
            question: this.preQuestionIdx,
            leaderboard: playersArray,
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

    close(socketIO: Server, socket: Socket) {
        for (const socketId of Object.keys(socketIO.sockets.adapter.rooms[this.sessionId].sockets)) {
            socketIO.sockets.connected[socketId].disconnect();
        }
        this.result = new QuizResult(
            this.sessionId,
            (this.questionIdx === 0 && this.readyForNextQuestion
                ? -1
                : this.readyForNextQuestion
                    ? this.preQuestionIdx
                    : this.preQuestionIdx - 1) + 1,
            this.quiz.questions.length,
            rankPlayer(this.playerMap)
        );
    }
}
