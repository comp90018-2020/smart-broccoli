import { Player, PlayerRecord } from "./datatype";

export class PointSystem {
    // base points for each question before apply streak factor etc
    private readonly pointsEachQuestion = 1000;
    // set of answered player, mainly used for calculate points factor
    public answeredPlayers: Set<number> = new Set([]);
    // the number of players that have give the right answer
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
            // greater streak get greater factor
            const factorStreak = streak * 0.1;
            // the higher rank and the more players are, the greater factor is given
            const factorRank =
                rank > totalPlayer ? 0 : (1 - rank / totalPlayer) / 2;
            return factor + (factorStreak < 1 ? factorStreak : 1) + factorRank;
        }
        return factor;
    }

    public setForNewQuestion() {
        this.rankOfNextRightAns = 0;
        this.answeredPlayers.clear();
    }

    public getPointsAndStreak(
        correct: boolean,
        playerId: number,
        streak: number,
        activePlayersNumber: number
    ) {
        if (this.answeredPlayers.has(playerId)) {
            // Changed answer
            return correct ? this.pointsEachQuestion : 0;
        } else {
            this.answeredPlayers.add(playerId);
            return Math.floor(
                this.getFactor(
                    correct,
                    correct ? this.getRankForARightAns() : activePlayersNumber,
                    streak,
                    activePlayersNumber
                ) * this.pointsEachQuestion
            );
        }
    }
}
