import { PointSystem } from "./points";
import { Res, GameStatus, QuizType, Player, Answer } from "./datatype";
import { QuizAttributes } from "../models/quiz";

export class GameSession {
    // session id from controller
    public id: number;
    public type: QuizType;
    // quiz from database
    public quiz: QuizAttributes;
    // game status
    public status: GameStatus = GameStatus.Pending;
    // host info
    public host: Player = null;
    // players info, user id to map
    public playerMap: { [playerId: number]: Player } = {};
    public nextQuestionIndex = 0;
    public questionIndex = 0;
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
                this.type = QuizType.Live_Group;
            } else {
                this.type = QuizType.SelfPaced_Group;
            }
        } else {
            if (sessionType === "live") {
                this.type = QuizType.Live_NotGroup;
            } else {
                this.type = QuizType.SelfPaced_NotGroup;
            }
        }
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

    nextQuestionIdx(): [Res, number] {
        const { questions } = this.quiz;
        if (this.nextQuestionIndex >= this.quiz.questions.length) {
            return [Res.NoMoreQuestion, -1];
        } else if (
            !this.isReadyForNextQuestion &&
            Object.keys(this.playerMap).length > 0
        ) {
            return [Res.ThereIsRunningQuestion, -1];
        } else {
            setTimeout(() => {
                if (this.nextQuestionIndex === this.questionIndex) {
                    this.setToNextQuestion();
                }
            }, this.quiz.timeLimit * 1000);
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
                answer.MCSelection === correctAnswer.MCSelection ? true : false;
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
        this.playerMap[playerId].preRecord = this.playerMap[playerId].record;
        this.playerMap[playerId].record = {
            questionNo: answer.questionNo,
            oldPos: this.playerMap[playerId].preRecord.newPos,
            newPos: null,
            bonusPoints: points,
            points: points + this.playerMap[playerId].preRecord.points,
            streak: streak,
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
