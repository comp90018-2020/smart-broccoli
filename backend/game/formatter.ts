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
    questionIndex: number
) => {
    // This question has been answered
    const [record] = player.genreateRecord(questionIndex);
    const { newPos } = record;

    let recordOfPlayerAhead: any;
    // Player does not has record but others have
    if (newPos === null && session.rankedRecords.length > 0)
        // Player ahead is the last one of the rank
        recordOfPlayerAhead = recordOfPlayerAhead =
            session.rankedRecords[session.rankedRecords.length - 1];
    // Player has record which is not at top1
    else if (newPos !== null && newPos !== 0)
        recordOfPlayerAhead = session.rankedRecords[newPos - 1];
    // Otherwise, player does not have player ahead
    else recordOfPlayerAhead = null;

    const questionOutcome = {
        question: questionIndex,
        leaderboard: session.rankedRecords.slice(0, 5),
        record: record,
        playerAhead: recordOfPlayerAhead,
    };
    return questionOutcome;
};
