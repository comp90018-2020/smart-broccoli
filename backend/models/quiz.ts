import { Question } from "models";
import Sequelize from "sequelize";

const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    title: {
        type: Sequelize.STRING,
        allowNull: true,
    },
    description: {
        type: Sequelize.STRING,
        allowNull: true,
    },
    type: {
        type: Sequelize.ENUM("live", "self paced"),
        allowNull: false,
    },
    timeLimit: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 10,
    },
};

interface QuizAttributes {
    id?: number;
    title?: string;
    description?: string;
    groupId: number;
    type: string;
    timeLimit?: number;
    questions?: Question[];
}

export default class Quiz extends Sequelize.Model<QuizAttributes>
    implements QuizAttributes {
    public title: string;
    public description: string;

    public readonly id!: number;
    public groupId: number;
    public type: string;
    public timeLimit?: number;
    public readonly questions?: Question[];

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
