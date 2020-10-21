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
    const quesionCopy = JSON.parse(
        JSON.stringify(session.quiz.questions[questionIndex])
    );
    if (!isHost) {
        quesionCopy.tf = null;
        if (quesionCopy.options !== null) {
            for (const index of Object.keys(quesionCopy.options)) {
                quesionCopy.options[Number(index)].correct = null;
            }
        }
    }
    return {
        no: questionIndex,
        text: quesionCopy.text,
        tf: quesionCopy.tf,
        options: quesionCopy.options,
        pictureId: quesionCopy.pictureId,
        time:
            process.env.NODE_EVN === "debug"
                ? 20000
                : session.quiz.timeLimit * 1000,
    };
};

/**
 *  format the complete welcome message of event-> welcome
 * @param playerMap player map
 */
export const formatWelcome = (playerMap: { [playerId: number]: Player }) => {
    const welcomeMessage: any[] = [];
    for (const [_, player] of Object.entries(playerMap)) {
        const { id, name, pictureId } = player;
        welcomeMessage.push({
            id: id,
            name: name,
            pictureId: pictureId,
        });
    }
    return welcomeMessage;
};

/**
 * format one player for event-> welcome
 * @param player a player
 */
export const formatPlayer = (player: Player) => {
    const { id, name, pictureId } = player;
    return {
        id: id,
        name: name,
        pictureId: pictureId,
    };
};

/**
 * format a player record for event-> questionOutcome
 * @param player a player
 */
export const formatPlayerRecord = (player: Player) => {
    const { id, name, pictureId, record } = player;
    delete record.questionNo;
    return {
        id: id,
        name: name,
        pictureId: pictureId,
        record: record,
    };
};
