import { Session } from "./session";
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
        text: quesionCopy.id,
        tf: quesionCopy.tf,
        options: quesionCopy.options,
        pictureId: quesionCopy.pictureId,
        time: 20,
    };
};
