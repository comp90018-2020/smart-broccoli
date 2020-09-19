import Sequelize from "sequelize";

const schema = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    text: {
        type: Sequelize.STRING,
        allowNULL: true,
    },
    type: {
        type: Sequelize.ENUM("choice", "truefalse"),
        allowNull: false,
    },
    tf: {
        type: Sequelize.BOOLEAN,
        allowNULL: true,
    },
    options: {
        type: Sequelize.JSONB,
        allowNULL: true,
    },
    timeLimit: {
        type: Sequelize.INTEGER,
        allowNULL: true,
    },
};

export interface OptionAttributes {
    correct: boolean;
    text: string;
}

interface QuestionAttributes {
    id?: number;
    quizId: number;
    text?: string;
    timeLimit?: number;
    type: string;
    tf?: boolean;
    options?: OptionAttributes[];
}

export default class Question extends Sequelize.Model<QuestionAttributes>
    implements QuestionAttributes {
    public text?: string;
    public timeLimit?: number;
    public type!: string;
    public tf?: boolean;
    public options?: OptionAttributes[];

    public readonly id!: number;
    public readonly quizId: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
