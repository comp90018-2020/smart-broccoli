import { GameSession, Player } from "./session";

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
            for (const [index, option] of Object.entries(quesionCopy.options)) {
                quesionCopy.options[index].correct = null;
            }
        }
    }

    return {
        id: questionIndex,
        text: quesionCopy.text,
        tf: quesionCopy.tf,
        options: quesionCopy.options,
        pictureId: quesionCopy.pictureId,
        time: 20,
    };
};


export const formatWelcome = (playerSet: Set<Player>) => {
    const welcomeMessage: any[] = [];
    for (const [_, player] of Object.entries(Array.from(playerSet))) {
        const { id, name, pictureId } = player;
        console.log(player);
        welcomeMessage.push({
            "id": id,
            "name": name,
            "pictureId": pictureId
        });
    }
    return welcomeMessage;
}

export const rankPlayer = (playerMap: { [key: string]: Player }) => {
    const playersArray: Player[] = [];
    for (const [playerId, player] of Object.entries(playerMap)) {
        playersArray.push(player);
    }
    // https://flaviocopes.com/how-to-sort-array-of-objects-by-property-javascript/
    playersArray.sort((a, b) =>
        a.record.points < b.record.points ? 1 : -1
    );
    return playersArray;
}

export const formatPlayer = (player: Player) => {
    const { id, name, pictureId, socketId, record } = player;
    return {
        "id": id,
        "name": name,
        "pictureId": pictureId
    };
}