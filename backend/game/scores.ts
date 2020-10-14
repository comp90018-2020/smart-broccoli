class AnswerRes {
    constructor(
        readonly correct: boolean,
        readonly rank: number,
        readonly streak: number,
        readonly rightParticipants: number,
        readonly totalParticipants: number
    ) { };
}

class PointsSystem {
    private readonly pointsEachQuestion = 1000;

    private getFactor(ansRes: AnswerRes): number {
        let base: number = ansRes.correct ? 1 : 0;
        if (base !== 0) {
            const a = ansRes.streak * 0.1;
            const b = (1 - ansRes.rightParticipants/ansRes.totalParticipants) / 2;
            return base * a * b;
        } 
        return base;
    }

    public getNewPoints(ansRes: AnswerRes): number{
        return Math.floor(this.getFactor(ansRes) * this.pointsEachQuestion);
    }
}