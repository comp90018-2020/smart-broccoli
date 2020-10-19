
export const formatQuestion = (question: any, isHost: boolean) => {
    const quesionCopy = JSON.parse(JSON.stringify(question));
    if(!isHost){
        quesionCopy.tf = null;
        if(quesionCopy.options!== null){
            for (const [index, option] of Object.entries(quesionCopy.options)) {
                quesionCopy.options[index].correct = null;
            }
        }
    }
    
    return {
        "id": quesionCopy.id,
        "text": quesionCopy.id,
        "tf": quesionCopy.tf,
        "options": quesionCopy.options,
        "pictureId": quesionCopy.pictureId,
        "time":20
      };
}

