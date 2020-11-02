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
    rankAll: Player[],
    rankFormated: any[]
) => {
    const { id: playerId, record } = player;
    const playerAheadRecord =
        record.newPos === null || record.newPos === 0
            ? null
            : rankAll[record.newPos - 1].formatRecord();

    const questionOutcome = {
        question: session.questionIndex,
        leaderboard: rankFormated,
        record: session.playerMap[Number(playerId)].formatRecord().record,
        playerAhead: playerAheadRecord,
    };
    return questionOutcome;
};

export const rankSlice = (rank: Player[], count?: number) => {
    if (count === undefined) {
        count = rank.length;
    }
    const top5: any[] = [];
    rank.slice(0, count).forEach((player) => {
        const { id, name, pictureId, record } = player;
        const { oldPos, newPos, bonusPoints, points, streak } = record;
        top5.push({
            player: {
                id: id,
                name: name,
                pictureId: pictureId,
            },
            record: {
                oldPos: oldPos,
                newPos: newPos,
                bonusPoints: bonusPoints,
                points: points,
                streak: streak,
            },
        });
    });
    return top5;
};
