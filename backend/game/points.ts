import { Player } from "./datatype";

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

    constructor() {
        this.setForNewQuestion();
    }

    public getRankForARightAns(): number {
        return this.rankOfNextRightAns++;
    }

    private getFactor(
        correct: boolean,
        rank: number,
        streak: number,
        totalPlayer: number
    ): number {
        const factor: number = correct ? 1 : 0;
        if (factor !== 0) {
            const factorStreak = (streak - 1) * 0.1;
            const factorRank = (1 - rank / totalPlayer) / 2;
            return factor + (factorStreak < 1 ? factorStreak : 1) + factorRank;
        }
        return factor;
    }

    public setForNewQuestion() {
        this.rankOfNextRightAns = 0;
        this.answeredPlayer = new Set([]);
    }

    public getPointsAnsStreak(
        correct: boolean,
        player: Player,
        totalPlayer: number
    ) {
        this.answeredPlayer.add(player.id);
        return {
            points: Math.floor(
                this.getFactor(
                    correct,
                    correct ? this.getRankForARightAns() : totalPlayer,
                    player.record.streak,
                    totalPlayer
                ) * this.pointsEachQuestion
            ),
            streak: correct ? player.record.streak + 1 : 0,
        };
    }
}
