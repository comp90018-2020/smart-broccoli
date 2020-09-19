import Sequelize from "sequelize";

const schema = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    text: {
        type: Sequelize.STRING,
        allowNULL: false,
    },
    timeLimit: {
        type: Sequelize.INTEGER,
        allowNULL: true,
    },
};

interface QuestionOptionAttributes {
    id?: number;
    ownerId: number;
    title?: string;
}

export default class QuestionOption
    extends Sequelize.Model<QuestionOptionAttributes>
    implements QuestionOptionAttributes {
    public title: string;
    public readonly id!: number;
    public readonly ownerId: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
