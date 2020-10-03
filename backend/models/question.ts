import Sequelize from "sequelize";

const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    text: {
        type: Sequelize.STRING,
        allowNull: true,
    },
    type: {
        type: Sequelize.ENUM("choice", "truefalse"),
        allowNull: false,
    },
    tf: {
        type: Sequelize.BOOLEAN,
        allowNull: true,
    },
    options: {
        type: Sequelize.JSONB,
        allowNull: true,
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
    type: string;
    tf?: boolean;
    options?: OptionAttributes[];
    pictureId?: number;
}

export default class Question
    extends Sequelize.Model<QuestionAttributes>
    implements QuestionAttributes {
    public text?: string;
    public type!: string;
    public tf?: boolean;
    public options?: OptionAttributes[];
    public pictureId?: number;

    public readonly id!: number;
    public readonly quizId: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
