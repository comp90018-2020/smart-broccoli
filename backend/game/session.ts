import { PointSystem } from "./points";
import { Res, GameStatus, GameType, Player, Answer } from "./datatype";
import { QuizAttributes } from "../models/quiz";

export class GameSession {
    // session id from controller
    public id: number;
    public type: GameType;
    // quiz from database
    public quiz: QuizAttributes;
    // game status
    public status: GameStatus = GameStatus.Pending;
    // host info
    public host: Player = null;
    // players info, user id to map
    public playerMap: { [playerId: number]: Player } = {};
    public nextQuestionIndex = -1;
    public questionIndex = -1;
    public quizStartsAt = 0;
    public preQuestionReleasedAt = 0;
    public isReadyForNextQuestion: boolean = true;
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

    getNextQuestionIndex(): [Res, number] {
        const { questions } = this.quiz;
        if (this.nextQuestionIndex >= this.quiz.questions.length) {
            return [Res.NoMoreQuestion, -1];
        } else if (
            !this.isReadyForNextQuestion &&
            Object.keys(this.playerMap).length > 0
        ) {
            return [Res.ThereIsRunningQuestion, -1];
        } else {
            this.questionIndex = this.nextQuestionIndex;
            this.preQuestionReleasedAt = Date.now();
            this.isReadyForNextQuestion = false;

            return [Res.Success, this.nextQuestionIndex];
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

    setToNextQuestion() {
        this.nextQuestionIndex = this.questionIndex + 1;
        this.pointSys.setForNewQuestion();
        this.isReadyForNextQuestion = true;
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
