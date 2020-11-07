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
        // Calculate the factor of streak
        const factorStreak = streak * 0.271828;
        // Calculate the factor of rank
        const factorRank =
            (1 - (rank + 1) / this.playersCountInThisQuestion) / 3.141592;
        // Add them and return
        return 1 + factorStreak + factorRank;
    }

    public reset() {
        // Reset
        this.rankOfNextRightAns = 0;
        this.answers = {};
        this.playersCountInThisQuestion = 0;
    }

    /**
     * Get points according to the passed in params
     * @param correct if the answer is correct or not
     * @param playerId player id
     * @param streak the times that get correct answers without break
     */
    public getPoints(correct: boolean, playerId: number, streak: number) {
        // Answer is not correct
        if (!correct) {
            this.answers[playerId] = 0;
            return 0;
        }
        if (this.answers.hasOwnProperty(playerId))
            if (this.answers[playerId] === 0) {
                // Has answered and was wrong
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
