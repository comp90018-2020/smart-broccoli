import { Session, Player } from "./session";

export const formatQuestion = (
    questionIndex: number,
    session: Session,
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


export const formatWelcome= (playerSet: Set<Player>)=>{
    const playerArray: any[] = JSON.parse(JSON.stringify(Array.from(playerSet)))
    for(let i = 0; i < playerArray.length; ++i){
        delete playerArray[i].record;
    }
    return playerArray;
}