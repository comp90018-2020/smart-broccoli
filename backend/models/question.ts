import { Picture } from "models";
import Sequelize, { Optional } from "sequelize";

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
    // Number of correct answers
    numCorrect: {
        type: Sequelize.VIRTUAL,
        get() {
            if (this.getDataValue("type") === "truefalse") return 1;
            return this.getDataValue("options").reduce(
                (accumulator: number, value: OptionAttributes) =>
                    // Accumulate when correct
                    accumulator + (value.correct ? 1 : 0),
                0
            );
        },
    },
};

export interface OptionAttributes {
    correct: boolean;
    text: string;
}

export interface QuestionAttributes {
    id: number;
    quizId: number;
    text?: string;
    type: string;
    tf?: boolean;
    options?: OptionAttributes[];
    pictureId?: number;
    numCorrect: number;
}
interface QuestionCreationAttributes
    extends Optional<QuestionAttributes, "id" | "numCorrect"> {}

export default class Question
    extends Sequelize.Model<QuestionAttributes, QuestionCreationAttributes>
    implements QuestionAttributes {
    public text?: string;
    public type!: string;
    public tf?: boolean;
    public options?: OptionAttributes[];
    public pictureId?: number;
    public Picture?: Picture;

    public readonly id: number;
    public readonly quizId: number;
    public readonly numCorrect: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
