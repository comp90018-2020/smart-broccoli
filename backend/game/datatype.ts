export enum GameErr {
    NoMoreQuestion = "No more question",
    ThereIsRunningQuestion = "There is player taking question",
}

export enum GameStatus {
    Pending,
    Starting,
    Running,
    Ended,
}

export class Player {
    public record: { [key: string]: any } = {};
    public preRecord: { [key: string]: any } = {};
    constructor(
        readonly id: number,
        readonly name: string,
        readonly pictureId: number,
        public socketId: string,
        public sessionId: number,
        public role: string
    ) {
        this.record.questionNo = 0;
        this.record.oldPos = null;
        this.record.newPos = null;
        this.record.bonusPoints = 0;
        this.record.points = 0;
        this.record.streak = -1;
        // deep copy
        this.preRecord = JSON.parse(JSON.stringify(this.record));
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
            id: this.id,
            name: this.name,
            pictureId: this.pictureId,
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

// WIP
export class GameResult {
    constructor(
        readonly sessionId: number,
        readonly questionFinshed: number,
        readonly questionTotal: number,
        readonly board: Player[]
    ) {}
}

export class Answer {
    constructor(
        readonly questionNo: number,
        readonly MCSelection: number,
        readonly TFSelection: boolean
    ) {}
}
