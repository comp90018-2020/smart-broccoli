import { PointSystem, Answer, AnswerOutcome } from "./points";
import { Socket, Server } from "socket.io";
import { rankPlayer, formatPlayerRecord } from "./formatter";
import { $socketIO } from "./index";

export enum GameStatus {
    Pending,
    Starting,
    Running,
    Ended,
}

export class GameResult {
    constructor(
        readonly sessionId: number,
        readonly questionFinshed: number,
        readonly questionTotal: number,
        readonly board: Player[]
    ) {}
}

export class Player {
    public record: { [key: string]: any } = {};
    constructor(
        readonly id: number,
        readonly name: string,
        readonly pictureId: number,
        public socketId: string,
        public sessionId: number,
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
    public status: GameStatus = GameStatus.Pending;
    public host: Player = null;
    public playerMap: { [playerId: number]: Player } = {};
    public playerAnsOutcomes: { [key: string]: AnswerOutcome } = {};
    private questionIdx = 0;
    private preQuestionIdx = 0;
    private quizStartsAt = 0;
    private questionReleasedAt = 0;
    public readyForNextQuestion: boolean = true;
    public pointSys: PointSystem = new PointSystem(0);
    public hasFinalBoardReleased: boolean = false;
    public result: GameResult = null;

    constructor($quiz: any, $sessionId: number) {
        this.sessionId = $sessionId;
        this.quiz = $quiz;
    }

    async addParticipant(player: Player) {
        if (player.role === "host") {
            if (this.host != null) {
                $socketIO.sockets.connected[this.host.socketId].disconnect();
            }
            this.host = player;
        } else {
            if (this.playerMap.hasOwnProperty(player.id)) {
                this.removeParticipant(player);
            }
            ++this.pointSys.participantCount;
            this.playerMap[player.id] = player;
            if (!this.playerAnsOutcomes.hasOwnProperty(player.id)) {
                this.playerAnsOutcomes[player.id] = new AnswerOutcome(
                    false,
                    null,
                    0,
                    -1
                );
            }
        }
    }

    async removeParticipant(player: Player) {
        if (player.socketId != this.playerMap[player.id].socketId) {
            $socketIO.sockets.connected[
                this.playerMap[player.id].socketId
            ].disconnect();
            delete this.playerMap[player.id];
            --this.pointSys.participantCount;
        }
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

    getAnsOfQuestion(questionIndex: number): Answer {
        const { tf, options } = this.quiz.questions[questionIndex];

        if (options === null) {
            return new Answer(questionIndex, null, tf);
        } else {
            let i = 0;
            for (const option of options) {
                if (option.correct) {
                    return new Answer(questionIndex, i, null);
                }
                ++i;
            }
            throw `No ans in Question[${questionIndex}], this should never happen.`;
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

    assessAns(playerId: number, answer: Answer) {
        const activeQuesionIdx = this.getActiveQuesionIdx();
        const correctAns = this.getAnsOfQuestion(activeQuesionIdx);
        const preAnsOut = this.getPreAnsOut(playerId);
        const answerOutcome: AnswerOutcome = this.checkAns(
            answer,
            correctAns,
            preAnsOut
        );
        // record in session that player has answered
        this.playerAnsOutcomes[playerId] = answerOutcome;
        this.pointSys.answeredPlayer.add(playerId);
        const points = this.pointSys.getNewPoints(answerOutcome);
        this.updateBoard(playerId, points, answerOutcome);
    }

    checkAns(
        ans: Answer,
        correctAns: Answer,
        preAnswerOutcome: AnswerOutcome
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
            console.log(correct);
            if (correct) {
                return new AnswerOutcome(
                    correct,
                    this.pointSys.getRankForARightAns(),
                    preAnswerOutcome.streak + 1,
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
        answerOutcome: AnswerOutcome
    ) {
        this.playerMap[playerId].record.oldPos = this.playerMap[
            playerId
        ].record.newPos;
        this.playerMap[playerId].record.newPos = null;
        this.playerMap[playerId].record.bonusPoints = points;
        this.playerMap[playerId].record.points =
            points + this.playerMap[playerId].record.points;
        this.playerMap[playerId].record.streak = answerOutcome.streak;
    }

    releaseBoard(hostSocket: Socket) {
        const playersArray = rankPlayer(this.playerMap);
        let i = 0;
        playersArray.forEach(({ id, record }) => {
            this.playerMap[id].record.oldPos = record.newPos;
            this.playerMap[id].record.newPos = i;
            ++i;
        });

        const rank = [];
        for (let i = 0; i < playersArray.length; ++i) {
            rank.push(formatPlayerRecord(playersArray[i]));
        }

        // socketIO.sockets.adapter.rooms[this.sessionId].sockets)
        for (const { id, socketId, record } of Object.values(this.playerMap)) {
            const playerAheadRecord =
                record.newPos === null
                    ? null
                    : record.newPos === 0
                    ? null
                    : rank[record.newPos - 1];
            const quesitonOutcome = {
                question: this.preQuestionIdx,
                leaderBoard: rank.slice(0, 5),
                record: this.playerMap[Number(id)].record,
                playerAhead: playerAheadRecord,
            };
            $socketIO.to(socketId).emit("questionOutcome", quesitonOutcome);
        }
        hostSocket.emit("questionOutcome", {
            question: this.preQuestionIdx,
            leaderboard: rank,
        });
    }

    setQuizStatus(status: GameStatus) {
        this.status = status;
    }

    setQuizStartsAt(timestamp: number) {
        this.quizStartsAt = timestamp;
    }

    getQuizStartsAt() {
        return this.quizStartsAt;
    }

    close(socketIO: Server, socket: Socket) {
        for (const socketId of Object.keys(
            socketIO.sockets.adapter.rooms[this.sessionId].sockets
        )) {
            socketIO.sockets.connected[socketId].disconnect();
        }
        this.result = new GameResult(
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
