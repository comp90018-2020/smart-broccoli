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
    timeLimit: {
        type: Sequelize.INTEGER,
        allowNULL: true,
    },
};

interface QuestionAttributes {
    id?: number;
    text?: string;
    timeLimit?: number;
    quizId: number;
}

export default class Question extends Sequelize.Model<QuestionAttributes>
    implements QuestionAttributes {
    public text?: string;
    public timeLimit?: number;

    public readonly id!: number;
    public readonly quizId: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
