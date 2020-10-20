export enum GameErr {
    NoMoreQuestion = "No more question",
    ThereIsRunningQuestion = "There is a running question",
}

export enum GameStatus {
    Pending,
    Starting,
    Running,
    Ended,
}

export class Player {
    public record: { [key: string]: any } = {};
    constructor(
        readonly id: number,
        readonly name: string,
        readonly pictureId: number,
        public socketId: string,
        public sessionId: number,
        public role: string
    ) {
        this.record.oldPos = null;
        this.record.newPos = null;
        this.record.bonusPoints = 0;
        this.record.points = 0;
        this.record.streak = -1;
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
