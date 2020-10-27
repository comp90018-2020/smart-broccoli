import { GameSession } from "./session";
import { GameStatus, Player } from "./datatype";
import { Session } from "models";

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
    const remainingTime =
        session.quiz.timeLimit * 1000 +
        session.preQuestionReleasedAt -
        Date.now();
    return {
        question: {
            no: questionIndex,
            text: questionCopy.text,
            tf: questionCopy.tf,
            options: questionCopy.options,
            pictureId: questionCopy.pictureId,
            numCorrect: questionCopy.numCorrect,
        },
        time:
            remainingTime < 0 || session.isReadyForNextQuestion
                ? 0
                : remainingTime,
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
    rank: any[]
) => {
    const { id, socketId, record } = player;
    const playerAheadRecord =
        record.newPos === null || record.newPos === 0
            ? null
            : rank[record.newPos - 1];
    // form question outcome
    const questionOutcome = {
        question: session.questionIndex,
        leaderboard: rank.slice(0, 5),
        record: session.playerMap[Number(id)].formatRecord().record,
        playerAhead: playerAheadRecord,
    };
    return questionOutcome;
};
