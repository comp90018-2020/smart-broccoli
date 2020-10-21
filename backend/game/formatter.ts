import { GameSession } from "./session";
import { Player } from "./datatype";

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
    // deep copy
    const questionCopy = JSON.parse(
        JSON.stringify(session.quiz.questions[questionIndex])
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
    return {
        no: questionIndex,
        text: questionCopy.text,
        tf: questionCopy.tf,
        options: questionCopy.options,
        pictureId: questionCopy.pictureId,
        time:
            process.env.NODE_EVN === "debug"
                ? 20000
                : session.quiz.timeLimit * 1000 +
                  session.preQuestionReleasedAt -
                  Date.now(),
    };
};

/**
 *  format the complete welcome message of event-> welcome
 * @param playerMap player map
 */
export const formatWelcome = (playerMap: { [playerId: number]: Player }) => {
    const welcomeMessage: any[] = [];
    for (const [_, player] of Object.entries(playerMap)) {
        welcomeMessage.push(player.profile());
    }
    return welcomeMessage;
};
