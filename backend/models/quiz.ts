import Sequelize, { Optional } from "sequelize";
import { Picture, Question, Session } from "models";
import { QuestionAttributes } from "./question";

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
        defaultValue: false,
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

export interface QuizAttributes {
    id?: number;
    title?: string;
    description?: string;
    groupId: number;
    type: string;
    active: boolean;
    pictureId?: number;
    timeLimit?: number;
    questions?: QuestionAttributes[];
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
    public readonly Sessions?: Session[];
    public readonly questions?: Question[];
    public readonly Picture?: Picture;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
