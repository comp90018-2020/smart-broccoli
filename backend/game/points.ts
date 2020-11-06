const POINTS_PER_QUESTION = 1000;

export class PointSystem {
    // Stores the points of last try if it exists
    public answers: { [id: number]: number };
    // The number of players that have give the correct answer
    private rankOfNextRightAns: number = 0;
    // How many players are in this question
    public playersCountInThisQuestion: number = 0;

    constructor() {}

    public getRankForCorrectAnswer(): number {
        return this.rankOfNextRightAns++;
    }

    private getFactorForCorrectAnswer(streak: number): number {
        // Get rank
        const rank = this.getRankForCorrectAnswer();
        // Calculate strak factor
        const factorStreak = streak * 0.271828;
        // Galculate rank factor
        const factorRank =
            (1 - (rank + 1) / this.playersCountInThisQuestion) / 3.141592;
        // Add them and return
        return 1 + factorStreak + factorRank;
    }

    public setForNewQuestion() {
        // Reset
        this.rankOfNextRightAns = 0;
        this.answers = {};
        this.playersCountInThisQuestion = 0;
    }

    public getPointsAndStreak(
        correct: boolean,
        playerId: number,
        streak: number
    ) {
        // Answer is not correct
        if (!correct) {
            this.answers[playerId] = 0;
            return 0;
        }
        if (this.answers.hasOwnProperty(playerId))
            if (this.answers[playerId] === 0) {
                // Was wrong
                this.answers[playerId] = POINTS_PER_QUESTION;
                return POINTS_PER_QUESTION;
            }
            // Was correct
            else return this.answers[playerId];
        else {
            // First time to answer
            this.answers[playerId] = Math.floor(
                POINTS_PER_QUESTION * this.getFactorForCorrectAnswer(streak)
            );
            return this.answers[playerId];
        }
    }
}
