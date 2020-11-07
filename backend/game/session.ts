import { PointSystem } from "./points";
import {
    GameStatus,
    GameType,
    Player,
    PlayerState,
    Answer,
    Role,
    RecordWithPlayerInfo,
} from "./datatype";
import { QuizAttributes } from "../models/quiz";
import {
    leaveSession,
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
    public status: GameStatus = GameStatus.Pending;
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
    // Stores the sorted records of the latest finished question
    public rankedRecords: RecordWithPlayerInfo[];

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

    /**
     * Player join this session and copy precious records if any
     * @param player Player
     */
    playerJoin(player: Player) {
        if (player.role === Role.host) {
            // If this is host
            this.host = player;
            // Set host's state to be joined
            this.setPlayerState(player, PlayerState.Joined);
            return;
        }
        // Otherwise, this is a player
        if (this.playerMap.hasOwnProperty(player.id))
            // If there is existed player with the same id
            // Copy records
            player.records = this.playerMap[player.id].records;
        // Set player table with the new connection
        this.playerMap[player.id] = player;
        // Set player state to be Joined
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

    isSelfPacedGroupAndHasNotStarted() {
        return (
            this.type === GameType.SelfPaced_Group &&
            (this.status === GameStatus.Pending ||
                this.status === GameStatus.Starting)
        );
    }

    isSelfPacedNotGroupAndHasNotStarted() {
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

    endSession() {
        const rank = this.rankPlayers();
        // Pass players' records to contoller
        const progress = rank.map(({ player: { id } }) => ({
            userId: id,
            data: this.playerMap[id].records,
            state: this.playerMap[id].state,
        }));

        if (process.env.SOCKET_MODE !== "debug") {
            endSessionInController(
                this.id,
                this.questionReleased.size === this.totalQuestions,
                progress
            );
        }
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

    assessAns(playerId: number, answer: Answer) {
        // Get the correct answer of this question
        const correctAnswer = this.getAnsOfQuestion(answer.question);
        const player = this.playerMap[playerId];
        // Check whether the provided answer is correct
        let correct;
        if (correctAnswer.MCSelection !== null)
            correct =
                JSON.stringify(answer.MCSelection) ===
                JSON.stringify(correctAnswer.MCSelection);
        else correct = answer.TFSelection === correctAnswer.TFSelection;

        // Get the record of previous question
        const [
            hasAnsweredPreviousQuestion,
            recordOfPreciousQuestion,
        ] = player.getRecordOfQuestion(answer.question - 1);

        const previousStreak = hasAnsweredPreviousQuestion
            ? recordOfPreciousQuestion.streak
            : 0;
        // Use the previous streak to get points
        const bonusPoints = this.pointSys.getPoints(
            correct,
            playerId,
            previousStreak
        );
        // New streak
        const streak = correct ? previousStreak + 1 : 0;

        // Generate record
        const [record, hasAnswered] = player.genreateRecord(this.questionIndex);
        if (hasAnswered)
            // If has answerd, roll back points first
            record.points -= record.bonusPoints;
        record.bonusPoints = bonusPoints;
        record.points += bonusPoints;
        record.streak = streak;

        // If has record for this question, overwrite
        if (hasAnswered) player.records[player.records.length - 1] = record;
        // Otherwise, add it to tail
        else this.playerMap[playerId].records.push(record);

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
            this.pointSys.reset();
        }
    }

    rankPlayers(): RecordWithPlayerInfo[] {
        // Convert players map to list for sorting
        const playersArray: Player[] = Object.values(this.playerMap);
        // Current question index
        const questionIndex = this.getQuestionIndex();
        // Make sure every user has record of current question
        playersArray.forEach((player, index) => {
            const [record, hasAnswered] = player.genreateRecord(questionIndex);
            if (!hasAnswered)
                // Player didn't answer, generate a record for him
                this.playerMap[player.id].records.push(record);
        });

        // Every user should have record of current question now

        // Sort records by points desc
        // https://flaviocopes.com/how-to-sort-array-of-objects-by-property-javascript/
        playersArray.sort((playerA, playerB) => {
            // All players should be ranked with their latest record
            // if they do not have record, use an initial one
            const [, playerARecord] = playerA.getLatestRecord();
            const [, playerBRecord] = playerB.getLatestRecord();
            return playerARecord.points < playerBRecord.points ? 1 : -1;
        });

        // Update players new position and new position
        playersArray.forEach(({ id }, position) => {
            // Update player's new position
            this.playerMap[id].records[questionIndex].newPos = position;
            playersArray[position].records[questionIndex].newPos = position;
            // Update the old position
            if (questionIndex === 0) {
                // If this is the first question, make them null
                this.playerMap[id].records[questionIndex].oldPos = null;
                playersArray[position].records[questionIndex].oldPos = null;
            } else {
                // Otherwise, get position from the record of previous questions
                const previousPosition = this.playerMap[id].records[
                    questionIndex - 1
                ].newPos;
                //  Update
                this.playerMap[id].records[
                    questionIndex
                ].oldPos = previousPosition;
                playersArray[position].records[
                    questionIndex
                ].oldPos = previousPosition;
            }
        });
        // Filter unused keys for emits according to the protocol
        this.rankedRecords = playersArray.map(
            (player) =>
                new RecordWithPlayerInfo(
                    player.profile(),
                    player.records[player.records.length - 1]
                )
        );
        return this.rankedRecords;
    }
}
