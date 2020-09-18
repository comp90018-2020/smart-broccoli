import Sequelize from "sequelize";

const schema = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    destination: {
        type: Sequelize.STRING,
        required: true,
    },
    filename: {
        type: Sequelize.STRING,
        required: true,
    },
    mimetype: {
        type: Sequelize.STRING,
        required: true,
    },
};

interface PictureAttributes {
    id?: number;
    filename: string;
    destination: string;
    mimetype: string;
}

export default class Picture extends Sequelize.Model<PictureAttributes>
    implements PictureAttributes {
    public readonly id!: number;
    public readonly filename!: string;
    public readonly destination!: string;
    public readonly mimetype!: string;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
