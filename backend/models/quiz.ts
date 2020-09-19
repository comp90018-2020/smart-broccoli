import Sequelize from "sequelize";

const schema = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    title: {
        type: Sequelize.STRING,
        allowNULL: true,
    },
    description: {
        type: Sequelize.STRING,
        allowNULL: true,
    },
};

interface QuizAttributes {
    id?: number;
    userId: number;
    title?: string;
    description?: string;
}

export default class Quiz extends Sequelize.Model<QuizAttributes>
    implements QuizAttributes {
    public title: string;
    public description: string;

    public readonly id!: number;
    public readonly userId: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
