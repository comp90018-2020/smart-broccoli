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

    latestRecord(questionIndex?: number) {
        if (questionIndex === undefined) {
            if (this.records.length === 0) return null;
            return this.records[this.records.length - 1];
        }

        const _latestRecord = this.records
            .slice()
            .find((record) => record.questionNo === questionIndex);
        return _latestRecord === undefined ? null : _latestRecord;
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
            record: {
                // @ts-ignore
                oldPos: null,
                // @ts-ignore
                newPos: null,
                bonusPoints: 0,
                points: 0,
                streak: 0,
            },
        };
        const _latestPreviousQuestionRecord = this.latestRecord(questionIndex);
        if (
            _latestPreviousQuestionRecord !== null &&
            _latestPreviousQuestionRecord.questionNo === questionIndex
        ) {
            const {
                oldPos,
                newPos,
                bonusPoints,
                points,
                streak,
            } = _latestPreviousQuestionRecord;
            record.record = {
                oldPos: oldPos,
                newPos: newPos,
                bonusPoints: bonusPoints,
                points: points,
                streak: streak,
            };
            return record;
        }

        const _latestRecord = this.latestRecord();
        if (_latestRecord === null) return record;
        const { oldPos, newPos, bonusPoints, points, streak } = _latestRecord;
        record.record = {
            oldPos: oldPos,
            newPos: newPos,
            bonusPoints: bonusPoints,
            points: points,
            streak: streak,
        };
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
