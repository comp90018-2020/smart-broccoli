import { GameSession } from "./session";
import { GameStatus, Player } from "./datatype";

/**
 * format question for event-> nextQuestion
 * @param questionIndex quesiont index
 * @param session session
 * @param isHost is host or not
 */
export const formatQuestion = (
    questionIndex: number,
    session: GameSession,
    isHost: boolean
) => {
    // @ts-ignore
    const questions = session.quiz.questions;
    const questionCopy: any = JSON.parse(
        JSON.stringify(questions[questionIndex])
    );
    if (!isHost) {
        if (questionCopy.tf !== null) {
            questionCopy.tf = null;
        } else {
            for (const option of questionCopy.options) {
                option.correct = null;
            }
        }
    }
    const remainingTime = session.QuestionReleaseAt[questionIndex] - Date.now();
    return {
        question: {
            id: questionCopy.id,
            no: questionIndex,
            text: questionCopy.text,
            tf: questionCopy.tf,
            options: questionCopy.options,
            pictureId: questionCopy.pictureId,
            numCorrect: questionCopy.numCorrect,
        },
        time: remainingTime < 0 ? 0 : remainingTime,
        totalQuestions: questions.length,
    };
};

/**
 *  format the complete welcome message of event-> welcome
 * @param playerMap player map
 */
export const formatWelcome = (
    role: string,
    gameStatus: GameStatus,
    playerMap: { [playerId: number]: Player }
) => {
    const players: any[] = [];
    for (const [_, player] of Object.entries(playerMap)) {
        players.push(player.profile());
    }
    return {
        players: players,
        role: role,
        status: gameStatus,
    };
};

export const formatQuestionOutcome = (
    session: GameSession,
    player: Player,
    questionIndex: number,
    rankAll: Player[],
    rankFormated: any[]
) => {
    // This question has been answered
    const _latestRecord = player.latestRecord(questionIndex);
    const playerAheadRecord =
        questionIndex === 0 ||
        rankAll.length === 0 ||
        (_latestRecord !== null && _latestRecord.newPos === 0)
            ? null
            : rankAll[
                  _latestRecord === null
                      ? rankAll.length - 1
                      : _latestRecord.newPos
              ].formatRecord(questionIndex);

    const questionOutcome = {
        question: questionIndex,
        leaderboard: rankFormated,
        record: session.playerMap[player.id].formatRecord(questionIndex).record,
        playerAhead: playerAheadRecord,
    };
    return questionOutcome;
};

export const rankSlice = (
    rank: Player[],
    currentIndex: number,
    count?: number
) => {
    if (count === undefined) count = rank.length;
    const topX: any[] = [];
    rank.slice(0, count).forEach((player) => {
        const { id, name, pictureId } = player;
        const record = player.latestRecord(currentIndex);
        const { oldPos, newPos, bonusPoints, points, streak } = record;
        topX.push({
            player: {
                id: id,
                name: name,
                pictureId: pictureId,
            },
            record: record ?? {
                oldPos: oldPos,
                newPos: newPos,
                bonusPoints: bonusPoints,
                points: points,
                streak: streak,
            },
        });
    });
    return topX;
};
