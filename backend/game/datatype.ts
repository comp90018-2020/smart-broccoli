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

// Player information
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
    // Records map
    public records: { [questionIndex: number]: Record } = {};
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
    profile(): PlayerBase {
        return new PlayerBase(this.id, this.name, this.pictureId);
    }

    /**
     * Get record of a question, if does not exist, return [false, Record]
     * @param questionIndex
     */
    getRecordOfQuestion(questionIndex: number): [boolean, Record] {
        // Find record of the question
        if (this.records.hasOwnProperty(questionIndex))
            // Find it
            return [true, this.records[questionIndex]];
        // Did not find
        return [false, null];
    }

    /**
     * Ger the record of a question
     * If there is no record of this question, generate one
     * Always return a record
     * @param questionIndex Question index
     */
    getOrGenerateRecord(questionIndex: number): [Record, boolean] {
        if (this.records.hasOwnProperty(questionIndex))
            // Player has record for this question
            return [this.records[questionIndex], true];
        // Player does not have record for this question
        // Get records of past questions
        const recordsOfPastQuestions = Object.fromEntries(
            Object.entries(this.records).filter(
                ([k, record]) => record.questionNo < questionIndex
            )
        );
        const recordsArray = Object.values(recordsOfPastQuestions);
        if (recordsArray.length === 0)
            // If there is no record of previous questions
            // Return an initial one
            return [new Record(questionIndex, null, null, 0, 0, 0), false];

        // If there is any, sort them desc
        recordsArray.sort((recordA, recordB) => {
            return recordA.questionNo < recordB.questionNo ? 1 : -1;
        });
        // Get the record which is cloest to current question
        const laestRecord = recordsArray[0];
        // Genretate the record of the query question
        return [
            new Record(questionIndex, null, null, 0, laestRecord.points, 0),
            false,
        ];
    }

    /**
     * Get record of question index and return as the protocol describes
     */
    formatRecordWithPlayerInfo(questionIndex: number): RecordWithPlayerInfo {
        const [record] = this.getOrGenerateRecord(questionIndex);
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
export class QuestionAnswered {
    constructor(
        public question: number,
        public count: number,
        public total: number
    ) {}
}
