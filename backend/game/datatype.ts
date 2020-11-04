export enum Event {
    welcome = "welcome",
    starting = "starting",
    questionAnswered = "questionAnswered",
    playerJoin = "playerJoin",
    playerLeave = "playerLeave",
    nextQuestion = "nextQuestion",
    correctAnswer = "correctAnswer",
    questionOutcome = "questionOutcome",
    cancelled = "cancelled",
    end = "end",
}

export enum Role {
    host = "host",
    player = "participant",
    all = "all above",
}

export enum GameStatus {
    Pending = "pending",
    Starting = "starting",
    Running = "running",
}

export enum GameType {
    SelfPaced_Group = "Self-Paced Group",
    SelfPaced_NotGroup = "Self-Paced Not Group",
    Live_Group = "Live Group",
    Live_NotGroup = "Live Not Group",
}
export enum PlayerState {
    Joined = "joined",
    Complete = "complete",
    Left = "complete",
}
export class Player {
    public record: { [key: string]: any } = {};
    public previousRecord: { [key: string]: any } = {};
    public state: PlayerState;
    constructor(
        readonly id: number,
        readonly name: string,
        readonly pictureId: number,
        public socketId: string,
        public sessionId: number,
        public role: string,
        public token: string
    ) {
        this.record.questionNo = 0;
        this.record.oldPos = null;
        this.record.newPos = null;
        this.record.bonusPoints = 0;
        this.record.points = 0;
        this.record.streak = 0;
        // deep copy
        this.previousRecord = JSON.parse(JSON.stringify(this.record));
    }

    /**
     * get profile of the player {id, name, pictureId}
     */
    profile() {
        return {
            id: this.id,
            name: this.name,
            pictureId: this.pictureId,
        };
    }

    /**
     * format record for event-> questionOutcome
     */
    formatRecord() {
        const { oldPos, newPos, bonusPoints, points, streak } = this.record;
        return {
            player: {
                id: this.id,
                name: this.name,
                pictureId: this.pictureId,
            },
            record: {
                oldPos: oldPos,
                newPos: newPos,
                bonusPoints: bonusPoints,
                points: points,
                streak: streak,
            },
        };
    }
}

export class Answer {
    constructor(
        readonly question: number,
        readonly MCSelection: number[],
        readonly TFSelection: boolean
    ) {
        if (MCSelection !== null) {
            this.MCSelection = this.MCSelection.sort();
        }
    }
}
