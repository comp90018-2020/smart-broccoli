export class AnswerOutcome {
    constructor(
        readonly correct: boolean,
        readonly rank: number,
        readonly streak: number,
        readonly questionNo: number
    ) {}
}

export class Answer {
    constructor(
        readonly questionNo: number,
        readonly MCSelection: number,
        readonly TFSelection: boolean
    ) {}
}

export class PointSystem {
    private readonly pointsEachQuestion = 1000;

    public answeredPlayer: Set<number> = new Set([]);
    private rankOfNextRightAns: number = 0;

    constructor(public participantCount: number) {
        this.setForNewQuestion();
    }

    public getRankForARightAns(): number {
        return this.rankOfNextRightAns++;
    }

    public hasAllPlayersAnswered() {
        return this.participantCount - this.answeredPlayer.size <= 0;
    }

    private getFactor(ansRes: AnswerOutcome): number {
        const factor: number = ansRes.correct ? 1 : 0;
        if (factor !== 0) {
            const factorStreak = ansRes.streak * 0.1;
            const factorRank = (1 - ansRes.rank / this.participantCount) / 2;
            return factor + (factorStreak < 1 ? factorStreak : 1) + factorRank;
        }
        return factor;
    }

    public setForNewQuestion() {
        this.rankOfNextRightAns = 0;
        this.answeredPlayer = new Set([]);
    }

    public getNewPoints(ansOutcome: AnswerOutcome): number {
        // if (!this.hasAllPlayersAnswered()) {
        //     throw "Wait for others to answer";
        // }
        return Math.floor(this.getFactor(ansOutcome) * this.pointsEachQuestion);
    }
}
