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

export class Record {
    constructor(
        public questionNo: number = null,
        public oldPos: number = null,
        public newPos: number = null,
        public bonusPoints: number = 0,
        public points: number = 0,
        public streak: number = 0
    ) {}
}

class PlayerBase {
    constructor(
        public id: number,
        public name: string,
        public pictureId: number
    ) {}
}

export class RecordWithPlayerInfo {
    constructor(
        public player: PlayerBase,
        public record: Record = new Record()
    ) {}
}

export class Player extends PlayerBase {
    public records: Record[] = [];
    public state: PlayerState = PlayerState.Joined;
    constructor(
        readonly id: number,
        readonly name: string,
        readonly pictureId: number,
        public socketId: string,
        public sessionId: number,
        public role: string,
        public token: string
    ) {
        super(id, name, pictureId);
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
     * Get record of a question, if does not exist, return [false, Record]
     * @param questionIndex
     */
    getRecordOfQuestion(questionIndex: number): [boolean, Record] {
        // Find record of the question
        const record = this.records.find(
            (record) => record.questionNo === questionIndex
        );
        // Did not find
        if (record === undefined)
            // Return initial record
            return [false, new Record(questionIndex, null, null, 0, 0, 0)];
        return [true, record];
    }

    /**
     * Get the latest record, boolean is false if cannot find
     */
    getLatestRecord(): [boolean, Record] {
        if (this.records.length === 0) return [false, null];
        return [true, this.records[this.records.length - 1]];
    }

    /**
     * Genreate the record of a question
     * @param questionIndex Question index
     */
    genreateRecord(questionIndex: number): [Record, boolean] {
        // Get record of this question
        const [
            didAnswerThisQuesion,
            recordOfThisQuestion,
        ] = this.getRecordOfQuestion(questionIndex);
        // Did answer this question
        if (didAnswerThisQuesion) return [recordOfThisQuestion, true];
        // Get latest record
        const [hasRecord, latestRecord] = this.getLatestRecord();
        if (!hasRecord)
            // If does not have record in history
            return [new Record(questionIndex, null, null, 0, 0, 0), false];
        // Otherwise, generate a new record of this question
        return [
            new Record(questionIndex, null, null, 0, latestRecord.points, 0),
            false,
        ];
    }

    /**
     * Get record of question index and return as the protocol describes
     */
    formatRecordWithPlayerInfo(questionIndex: number): RecordWithPlayerInfo {
        const [record] = this.genreateRecord(questionIndex);
        return new RecordWithPlayerInfo(this, record);
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
