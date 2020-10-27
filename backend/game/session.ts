import { PointSystem } from "./points";
import { Res, GameStatus, GameType, Player, Answer, Role } from "./datatype";
import { QuizAttributes } from "../models/quiz";
import { Session } from "models";
import game from "game";
import { stat } from "fs";

const WAIT_TIME_BEFORE_START = 10 * 1000;

export class GameSession {
    // session id from controller
    public id: number;
    public type: GameType;
    // quiz from database
    public quiz: QuizAttributes;
    // game status
    private status: GameStatus = GameStatus.Pending;
    // host info
    public host: Player = null;
    // players info, user id to map
    public playerMap: { [playerId: number]: Player } = {};
    public questionIndex = -1;
    public quizStartsAt = 0;
    public preQuestionReleasedAt = 0;
    public _isReadyForNextQuestion: boolean = true;
    public pointSys: PointSystem = new PointSystem();

    constructor(
        $quiz: QuizAttributes,
        $sessionId: number,
        sessionType: string,
        isGroup: boolean
    ) {
        this.id = $sessionId;
        this.quiz = $quiz;
        if (isGroup) {
            // "live", "self paced"
            if (sessionType === "live") {
                this.type = GameType.Live_Group;
            } else {
                this.type = GameType.SelfPaced_Group;
            }
        } else {
            if (sessionType === "live") {
                this.type = GameType.Live_NotGroup;
            } else {
                this.type = GameType.SelfPaced_NotGroup;
            }
        }
    }

    hasUser(player: Player) {
        return this.playerMap.hasOwnProperty(player.id);
    }
    setHost(player: Player) {
        this.host = player;
    }
    setPlayer(player: Player) {
        this.playerMap[player.id] = player;
    }

    getPlayer(playerId: number) {
        return this.playerMap[playerId];
    }

    isSelfPacedGroupAndHasNotStarted() {
        return (
            this.type === GameType.SelfPaced_Group &&
            (this.status === GameStatus.Pending ||
                this.status === GameStatus.Starting)
        );
    }
    isSelfPacedNotGroupAndPending() {
        return (
            this.status === GameStatus.Pending &&
            this.type == GameType.SelfPaced_NotGroup
        );
    }
    isEmitValid(player: Player) {
        return this.type === GameType.SelfPaced_Group && player !== undefined;
    }
    isSelfPacedGroup() {
        return this.type === GameType.SelfPaced_Group;
    }
    isSelfPacedNotGroup() {
        return this.type === GameType.SelfPaced_NotGroup;
    }
    isReadyForNextQuestion() {
        return this._isReadyForNextQuestion;
    }

    is(status: GameStatus) {
        return this.status == status;
    }
    hasMoreQuestions() {
        return this.questionIndex < this.quiz.questions.length - 1;
    }

    canAbort(player: Player) {
        return (
            this.type === GameType.SelfPaced_Group ||
            this.type === GameType.SelfPaced_NotGroup ||
            player.role === Role.host
        );
    }
    setStatus(status: GameStatus) {
        if (status == GameStatus.Starting) {
            this.status = GameStatus.Starting;
            this.quizStartsAt = Date.now() + WAIT_TIME_BEFORE_START;
        } else if (status == GameStatus.Running) {
            this.status = GameStatus.Running;
        }
    }
    getStatus() {
        return this.status;
    }
    canStart(player: Player) {
        // and game is pending
        return (
            this.status == GameStatus.Pending &&
            // if no host or player is host
            (this.type === GameType.SelfPaced_Group ||
                this.type === GameType.SelfPaced_NotGroup ||
                player.role === Role.host)
        );
    }
    canReleaseTheFirstQuestion() {
        return Date.now() > this.quizStartsAt;
    }
    isAnswerNoCorrect(answer: Answer) {
        return answer.questionNo === this.questionIndex;
    }
    hasAllPlayerAnswered() {
        return (
            this.pointSys.answeredPlayers.size >=
            Object.keys(this.playerMap).length
        );
    }

    canReleaseNextQuestion(player: Player, nextQuestionIndex: number) {
        return (
            this.questionIndex === nextQuestionIndex &&
            this._isReadyForNextQuestion &&
            this.status === GameStatus.Running &&
            // if no host or player is host
            (this.type === GameType.SelfPaced_Group ||
                this.type === GameType.SelfPaced_NotGroup ||
                player.role === Role.host)
        );
    }

    isSelfPaced() {
        return (
            this.type == GameType.SelfPaced_Group || GameType.SelfPaced_NotGroup
        );
    }
    canAnswer(player: Player) {
        // is player
        return (
            player.role === Role.player &&
            // and there is a conducting question
            !this._isReadyForNextQuestion &&
            // and this player has not answered
            !this.pointSys.answeredPlayers.has(player.id)
        );
    }
    canShowBoard(player: Player) {
        return (
            this._isReadyForNextQuestion &&
            (this.type === GameType.SelfPaced_Group ||
                player.role === Role.host)
        );
    }

    canEmitStarting() {
        return (
            this.isSelfPacedGroupAndHasNotStarted() &&
            Date.now() > this.quizStartsAt
        );
    }

    canEmitCorrectAnswer() {
        return (
            this._isReadyForNextQuestion &&
            this.questionIndex >= 0 &&
            this.questionIndex < this.quiz.questions.length
        );
    }

    canSetToNextQuestion(nextQuestionIndex: number) {
        return (
            this._isReadyForNextQuestion &&
            nextQuestionIndex === this.questionIndex
        );
    }

    getAnsOfQuestion(questionIndex: number): Answer {
        const { tf, options } = this.quiz.questions[questionIndex];

        if (options === null) {
            return new Answer(questionIndex, null, tf);
        } else {
            let i = 0;
            const correctOptions: number[] = [];
            for (const option of options) {
                if (option.correct) {
                    correctOptions.push(i);
                }
                ++i;
            }
            return new Answer(questionIndex, correctOptions, null);
        }
    }

    assessAns(playerId: number, answer: Answer) {
        const correctAnswer = this.getAnsOfQuestion(this.questionIndex);
        const player = this.playerMap[playerId];

        let correct;
        if (correctAnswer.MCSelection !== null) {
            correct =
                JSON.stringify(answer.MCSelection) ===
                JSON.stringify(correctAnswer.MCSelection);
        } else {
            correct =
                answer.TFSelection === correctAnswer.TFSelection ? true : false;
        }

        // get points and streak
        const { points, streak } = this.pointSys.getPointsAnsStreak(
            correct,
            player,
            Object.keys(this.playerMap).length
        );

        this.playerMap[playerId].previousRecord = this.playerMap[
            playerId
        ].record;
        const previousRecord = this.playerMap[playerId].previousRecord;
        this.playerMap[playerId].record = {
            questionNo: answer.questionNo,
            oldPos:
                previousRecord.questionNo === answer.questionNo
                    ? this.playerMap[playerId].previousRecord.newPos
                    : null,
            newPos: null,
            bonusPoints: points,
            points: points + this.playerMap[playerId].previousRecord.points,
            streak:
                previousRecord.questionNo === answer.questionNo ? streak : 0,
        };
    }
    getQuestionIndex() {
        return this.questionIndex;
    }

    setToNextQuestion(nextQuestionIndex: number) {
        if (this.questionIndex === nextQuestionIndex - 1) {
            this.questionIndex += 1;
            this._isReadyForNextQuestion = true;
            this.pointSys.setForNewQuestion();
        }
    }

    rankPlayers() {
        const playersArray: Player[] = [];
        for (const [playerId, player] of Object.entries(this.playerMap)) {
            playersArray.push(player);
        }
        // https://flaviocopes.com/how-to-sort-array-of-objects-by-property-javascript/
        playersArray.sort((a, b) =>
            a.record.points < b.record.points ? 1 : -1
        );
        for (const [rank, player] of Object.entries(playersArray)) {
            this.playerMap[player.id].record.newPos = Number(rank);
        }
        let order = 0;
        playersArray.forEach(({ id, record }) => {
            this.playerMap[id].record.oldPos = record.newPos;
            this.playerMap[id].record.newPos = order;
            ++order;
        });

        const rank = [];
        for (let i = 0; i < playersArray.length; ++i) {
            rank.push(playersArray[i].formatRecord());
        }

        return rank;
    }
}
