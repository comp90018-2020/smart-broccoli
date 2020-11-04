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

export class PlayerRecord {
    constructor(
        public questionNo: number = null,
        public oldPos: number = null,
        public newPos: number = null,
        public bonusPoints: number = 0,
        public points: number = 0,
        public streak: number = 0
    ) {}
}

export class Player {
    public records: PlayerRecord[] = [];
    public state: PlayerState = PlayerState.Joined;
    constructor(
        readonly id: number,
        readonly name: string,
        readonly pictureId: number,
        public socketId: string,
        public sessionId: number,
        public role: string,
        public token: string
    ) {}

    latestRecord() {
        if (this.records.length > 0)
            return this.records[this.records.length - 1];
        else return null;
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
    formatRecord(questionIndex: number) {
        const record = {
            player: {
                id: this.id,
                name: this.name,
                pictureId: this.pictureId,
            },
            record: {},
        };
        const _lastestRecord = this.latestRecord();
        if (
            _lastestRecord !== null &&
            _lastestRecord.questionNo === questionIndex
        ) {
            const {
                oldPos,
                newPos,
                bonusPoints,
                points,
                streak,
            } = _lastestRecord;
            record.record = {
                oldPos: oldPos,
                newPos: newPos,
                bonusPoints: bonusPoints,
                points: points,
                streak: streak,
            };
        } else record.record = null;
        return record;
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
