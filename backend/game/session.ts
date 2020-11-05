import { PointSystem } from "./points";
import {
    GameStatus,
    GameType,
    Player,
    PlayerState,
    Answer,
    Role,
    PlayerRecord,
} from "./datatype";
import { QuizAttributes } from "../models/quiz";
import {
    leaveSession,
    activateSession,
    endSession as endSessionInController,
} from "../controllers/session";

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
    public questionIndex: number = -1;
    public QuestionReleaseAt: { [questionIndex: number]: number } = {};
    public preQuestionReleasedAt: number = 0;
    public _isReadyForNextQuestion: boolean = true;
    public pointSys: PointSystem = new PointSystem();
    public activePlayersNum: number = 0;
    private invalidTokens: Set<String> = new Set([]);
    public boardReleased: Set<number> = new Set([]);
    public questionReleased: Set<number> = new Set([]);
    public answerReleased: Set<number> = new Set([]);
    public totalQuestions: number = 0;
    public updatedAt: number = Date.now();

    constructor(
        $quiz: QuizAttributes,
        $sessionId: number,
        sessionType: string,
        isGroup: boolean
    ) {
        this.id = $sessionId;
        this.quiz = $quiz;
        this.totalQuestions = this.quiz.questions.length;

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
                this.status = GameStatus.Running;
                this.setToNextQuestion(0);
            }
        }
    }

    updatingTime() {
        this.updatedAt = Date.now();
    }

    hasFinalBoardReleased() {
        return this.boardReleased.has(this.totalQuestions - 1);
    }

    deactivateToken(token: string) {
        this.invalidTokens.add(token);
    }

    isTokenDeactivated(token: string) {
        return this.invalidTokens.has(token);
    }

    hasUser(player: Player) {
        if (player.role == Role.player)
            return (
                this.playerMap.hasOwnProperty(player.id) &&
                this.playerMap[player.id].state !== PlayerState.Left
            );
        return true;
    }

    hostJoin(player: Player) {
        this.host = player;
        this.setPlayerState(player, PlayerState.Joined);
    }

    playerJoin(player: Player) {
        this.playerMap[player.id] = player;
        this.setPlayerState(player, PlayerState.Joined);
    }

    canSendQuesionAfterReconnection() {
        return this.visibleQuestionIndex() !== -1;
    }

    visibleQuestionIndex() {
        if (this._isReadyForNextQuestion) {
            return this.questionIndex - 1;
        } else {
            return this.questionIndex;
        }
    }

    freezeQuestion(questionIndex: number) {
        if (questionIndex === this.questionIndex) {
            this._isReadyForNextQuestion = false;
        }
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

    isSelfPacedNotGroupAndHasNotStart() {
        return (
            this.questionIndex === 0 &&
            this._isReadyForNextQuestion &&
            this.type === GameType.SelfPaced_NotGroup
        );
    }

    isEmitValid(player: Player) {
        return (
            (player !== undefined &&
                (player.role === Role.host ||
                    this.type == GameType.SelfPaced_NotGroup)) ||
            player == undefined
        );
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
        return this.status === status;
    }

    hasMoreQuestions() {
        return this.questionIndex < this.totalQuestions - 1;
    }

    async playerLeave(player: Player) {
        if (process.env.SOCKET_MODE !== "debug") {
            await leaveSession(player.sessionId, player.id);
        }
        this.setPlayerState(player, PlayerState.Left);
    }

    getQuizTimeLimit() {
        return this.quiz.timeLimit === undefined
            ? 10 * 1000
            : this.quiz.timeLimit * 1000;
    }

    setQuestionReleaseTime(questionIndex: number, afterTime: number) {
        this.QuestionReleaseAt[questionIndex] = Date.now() + afterTime;
    }

    setPlayerState(player: Player, state: PlayerState) {
        if (player.role === Role.player) {
            if (state === PlayerState.Joined) {
                this.activePlayersNum += 1;
            } else if (state === PlayerState.Left) {
                this.activePlayersNum -= 1;
            }
            this.playerMap[player.id].state = state;
        } else if (player.role === Role.host) {
            this.host.state = state;
        }
    }

    canAbort(player: Player) {
        return player === undefined || player.role === Role.host;
    }

    async setStatus(status: GameStatus) {
        this.status = status;
        if (status === GameStatus.Starting) {
            this.QuestionReleaseAt[0] = Date.now() + WAIT_TIME_BEFORE_START;

            if (process.env.SOCKET_MODE !== "debug") {
                await activateSession(this.id);
            }
        }
    }

    endSession() {
        const rank = this.rankPlayers();
        const progress = rank.map(({ id, records, state }) => ({
            userId: id,
            data: records,
            state: state,
        }));

        if (process.env.SOCKET_MODE !== "debug") {
            endSessionInController(
                this.id,
                this.questionReleased.size === this.totalQuestions,
                progress
            );
        }
    }

    getStatus() {
        return this.status;
    }

    canStart(player: Player) {
        // and game is pending
        return (
            this.status === GameStatus.Pending &&
            // if no host or player is host
            (this.type === GameType.SelfPaced_Group ||
                this.type === GameType.SelfPaced_NotGroup ||
                player.role === Role.host)
        );
    }

    canReleaseTheFirstQuestion() {
        return (
            this.QuestionReleaseAt.hasOwnProperty(0) &&
            Date.now() > this.QuestionReleaseAt[0]
        );
    }

    isAnswerNoCorrect(answer: Answer) {
        return answer.question === this.questionIndex;
    }

    hasAllPlayerAnswered() {
        return this.pointSys.answeredPlayers.size >= this.activePlayersNum;
    }

    canReleaseNextQuestion(player: Player, nextQuestionIndex: number) {
        return (
            nextQuestionIndex < this.totalQuestions &&
            !this.questionReleased.has(nextQuestionIndex) &&
            this.questionIndex === nextQuestionIndex &&
            this._isReadyForNextQuestion &&
            this.status === GameStatus.Running &&
            // if no host or player is host
            (this.type === GameType.SelfPaced_Group ||
                this.type === GameType.SelfPaced_NotGroup ||
                (player !== undefined && player.role === Role.host))
        );
    }

    isSelfPaced() {
        return (
            this.type === GameType.SelfPaced_Group ||
            this.type === GameType.SelfPaced_NotGroup
        );
    }

    canAnswer(player: Player, answer: Answer, currentQuestionIndex: number) {
        // is player
        return (
            !this._isReadyForNextQuestion &&
            answer.question === this.questionIndex &&
            this.questionIndex === currentQuestionIndex &&
            player.role === Role.player
        );
    }

    canShowBoard(player: Player) {
        return (
            this.questionIndex !== -1 &&
            this._isReadyForNextQuestion &&
            !this.boardReleased.has(this.questionIndex - 1) &&
            !this.hasFinalBoardReleased() &&
            (player === undefined || player.role === Role.host)
        );
    }

    canEmitStarting() {
        return (
            this.isSelfPacedGroupAndHasNotStarted() &&
            !this.QuestionReleaseAt.hasOwnProperty(0)
        );
    }

    canEmitCorrectAnswer() {
        return (
            this._isReadyForNextQuestion &&
            this.questionIndex >= 0 &&
            this.questionIndex < this.totalQuestions
        );
    }

    canSetToNextQuestion(questionIndex: number) {
        return questionIndex === this.questionIndex;
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

    assessAns(playerId: number, answer: Answer, currentQuestionIndex: number) {
        const correctAnswer = this.getAnsOfQuestion(currentQuestionIndex);
        const player = this.playerMap[playerId];

        let correct;
        if (correctAnswer.MCSelection !== null) {
            correct =
                JSON.stringify(answer.MCSelection) ===
                JSON.stringify(correctAnswer.MCSelection);
        } else {
            correct = answer.TFSelection === correctAnswer.TFSelection;
        }

        const _latestRecord = this.playerMap[playerId].latestRecord(
            currentQuestionIndex
        );

        // get points and streak
        const { points, streak } = this.pointSys.getPointsAndStreak(
            correct,
            playerId,
            _latestRecord !== null &&
                _latestRecord.questionNo + 1 === answer.question
                ? _latestRecord.streak
                : 0,
            this.activePlayersNum
        );

        this.playerMap[playerId].records.push(
            new PlayerRecord(
                answer.question,
                _latestRecord !== null &&
                    _latestRecord.questionNo + 1 === answer.question
                    ? _latestRecord.newPos
                    : null,
                null,
                points,
                points + (_latestRecord !== null ? _latestRecord.points : 0),
                _latestRecord !== null &&
                    _latestRecord.questionNo + 1 === answer.question
                    ? streak
                    : 0
            )
        );

        if (this.answerReleased.size === this.totalQuestions)
            this.playerMap[player.id].state = PlayerState.Complete;
    }

    getQuestionIndex() {
        return !this._isReadyForNextQuestion
            ? this.questionIndex
            : this.questionIndex - 1;
    }

    setToNextQuestion(nextQuestionIndex: number) {
        if (
            0 <= nextQuestionIndex &&
            nextQuestionIndex <= this.totalQuestions
        ) {
            this.questionIndex = nextQuestionIndex;
            this._isReadyForNextQuestion = true;
            this.pointSys.setForNewQuestion();
        }
    }

    rankPlayers() {
        const playersArray: Player[] = Object.values(this.playerMap);
        const currentQuestionIndex = this.getQuestionIndex();
        // https://flaviocopes.com/how-to-sort-array-of-objects-by-property-javascript/
        playersArray.sort((a, b) => {
            const aRecord = a.latestRecord(currentQuestionIndex);
            const bRecord = b.latestRecord(currentQuestionIndex);
            return bRecord === null || aRecord.points < bRecord.points ? 1 : -1;
        });

        playersArray.forEach(({ id }, ranking) => {
            const lastRecordIndex = this.playerMap[id].records.length - 1;
            const lastestRecord = this.playerMap[id].latestRecord(
                currentQuestionIndex
            );
            if (lastestRecord !== null) {
                this.playerMap[id].records[lastRecordIndex].newPos = ranking;
                this.playerMap[id].records[lastRecordIndex].oldPos =
                    lastestRecord.newPos;
                playersArray[ranking].records[lastRecordIndex].newPos = ranking;
                playersArray[ranking].records[lastRecordIndex].oldPos =
                    lastestRecord.newPos;
            }
        });
        return playersArray;
    }
}
