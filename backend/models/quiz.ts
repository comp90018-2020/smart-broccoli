import { Question } from "models";
import Sequelize, { Optional } from "sequelize";

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
    active: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
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
    active: boolean;
    pictureId?: number;
    timeLimit?: number;
    questions?: Question[];
}
interface QuizCreationAttributes
    extends Optional<QuizAttributes, "id" | "active"> {}

export default class Quiz
    extends Sequelize.Model<QuizAttributes, QuizCreationAttributes>
    implements QuizAttributes {
    public title: string;
    public description: string;

    public readonly id!: number;
    public groupId: number;
    public type: string;
    public active: boolean;
    public timeLimit?: number;
    public pictureId?: number;
    public readonly questions?: Question[];

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
