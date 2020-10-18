export class AnswerOutcome {
    constructor(
        readonly correct: boolean,
        readonly rank: number,
        readonly streak: number,
        readonly quesionNo: number
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
        let factor: number = ansRes.correct ? 1 : 0;
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

    public checkAns(
        ans: Answer,
        correctAns: Answer,
        preAnsOutcome: AnswerOutcome
    ): AnswerOutcome {
        if (ans.questionNo !== correctAns.questionNo) {
            throw `This is ans for question ${ans.questionNo} not for ${correctAns.questionNo}`;
        } else {
            const correct =
                correctAns.MCSelection !== null
                    ? ans.MCSelection === correctAns.MCSelection
                        ? true
                        : false
                    : ans.TFSelection === correctAns.TFSelection
                    ? true
                    : false;
            return new AnswerOutcome(
                correct,
                correct ? this.getRankForARightAns() : this.participantCount,
                correct ? preAnsOutcome.streak + 1 : 0,
                correctAns.questionNo
            );
        }
    }

    public getNewPoints(ansOutcome: AnswerOutcome): number {
        // if (!this.hasAllPlayersAnswered()) {
        //     throw "Wait for others to answer";
        // }
        return Math.floor(this.getFactor(ansOutcome) * this.pointsEachQuestion);
    }
}
