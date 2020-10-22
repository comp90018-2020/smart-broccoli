import { Socket, Server } from "socket.io";
import { PointSystem } from "./points";
import { $socketIO } from "./index";
import { GameErr, GameStatus, Player, GameResult, Answer } from "./datatype";
import Quiz from "../models/quiz";
import { endSession } from "../controllers/session";

export class GameSession {
    // session id from controller
    private sessionId: number;
    // quiz from database
    public quiz: Quiz;
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
    public hasFinalRankReleased: boolean = false;

    constructor($quiz: Quiz, $sessionId: number) {
        this.sessionId = $sessionId;
        this.quiz = $quiz;
    }

    async addParticipant(player: Player) {
        console.log("try add", player.socketId, player.role);
        if (player.role === "host") {
            if (
                this.host != null &&
                this.host.socketId != player.socketId &&
                $socketIO.sockets.connected.hasOwnProperty(this.host.socketId)
            ) {
                $socketIO.sockets.connected[this.host.socketId].disconnect();
            }
            this.host = player;
            console.log("new host", player.socketId);
        } else {
            if (this.playerMap.hasOwnProperty(player.id)) {
                this.removeParticipant(player, false);
            }
            this.playerMap[player.id] = player;
            console.log("participant", player.socketId);
        }
    }

    async removeParticipant(player: Player, isForce: boolean) {
        if (
            (isForce ||
                player.socketId != this.playerMap[player.id].socketId) &&
            $socketIO.sockets.connected.hasOwnProperty(
                this.playerMap[player.id].socketId
            )
        ) {
            $socketIO.sockets.connected[
                this.playerMap[player.id].socketId
            ].disconnect();
            delete this.playerMap[player.id];
        }
    }

    async hasParticipant(playerId: number) {
        return this.playerMap.hasOwnProperty(playerId);
    }

    isCurrQuestionActive() {
        return this.questionIndex === this.nextQuestionIndex;
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

    nextQuestionIdx(): number {
        if (this.nextQuestionIndex >= this.quiz.questions.length) {
            throw GameErr.NoMoreQuestion;
        } else if (
            !this.isReadyForNextQuestion &&
            Object.keys(this.playerMap).length > 0
        ) {
            throw GameErr.ThereIsRunningQuestion;
        } else {
            setTimeout(() => {
                if (this.nextQuestionIndex === this.questionIndex) {
                    this.setToNextQuestion();
                }
            }, this.quiz.timeLimit * 1000);
            this.questionIndex = this.nextQuestionIndex;
            this.preQuestionReleasedAt = Date.now();
            this.isReadyForNextQuestion = false;

            return this.nextQuestionIndex;
        }
    }

    assessAns(playerId: number, answer: Answer) {
        const correctAnswer = this.getAnsOfQuestion(this.questionIndex);
        const player = this.playerMap[playerId];
        // if this answer is correct
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
        return playersArray;
    }

    releaseBoard(hostSocket: Socket) {
        const playersArray = this.rankPlayers();
        let i = 0;
        playersArray.forEach(({ id, record }) => {
            this.playerMap[id].record.oldPos = record.newPos;
            this.playerMap[id].record.newPos = i;
            ++i;
        });

        const rank = [];
        for (let i = 0; i < playersArray.length; ++i) {
            rank.push(playersArray[i].formatRecord());
        }

        // socketIO.sockets.adapter.rooms[this.sessionId].sockets)
        for (const { id, socketId, record } of Object.values(this.playerMap)) {
            const playerAheadRecord =
                record.newPos === null
                    ? null
                    : record.newPos === 0
                    ? null
                    : rank[record.newPos - 1];
            const questionOutcome = {
                question: this.questionIndex,
                leaderBoard: rank.slice(0, 5),
                record: this.playerMap[Number(id)].record,
                playerAhead: playerAheadRecord,
            };
            $socketIO.to(socketId).emit("questionOutcome", questionOutcome);
        }
        hostSocket.emit("questionOutcome", {
            question: this.questionIndex,
            leaderboard: rank,
        });
    }

    close(socketIO: Server, socket: Socket) {
        for (const socketId of Object.keys(
            socketIO.sockets.adapter.rooms[this.sessionId].sockets
        )) {
            socketIO.sockets.connected[socketId].disconnect();
        }

        // WIP: endSession()
        // const result = new GameResult(
        //     this.sessionId,
        //     (this.questionIndex === 0 && this.readyForNextQuestion
        //         ? -1
        //         : this.readyForNextQuestion
        //         ? this.preQuestionIndex
        //         : this.preQuestionIndex - 1) + 1,
        //     this.quiz.questions.length,
        //     rankPlayer(this.playerMap)
        // );
    }
}
