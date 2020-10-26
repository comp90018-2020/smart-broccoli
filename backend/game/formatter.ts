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
    const remainingTime =
        session.quiz.timeLimit * 1000 +
        session.preQuestionReleasedAt -
        Date.now();
    return {
        no: questionIndex,
        text: questionCopy.text,
        tf: questionCopy.tf,
        options: questionCopy.options,
        pictureId: questionCopy.pictureId,
        time: remainingTime < 0 ? 0 : remainingTime,
        totalQuestions: questions.length,
        numCorrect: questionCopy.numCorrect,
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
