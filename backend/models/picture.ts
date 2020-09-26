import Sequelize, { Optional } from "sequelize";

// Represents pictures that are stored locally
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    destination: {
        type: Sequelize.STRING,
        allowNull: true,
    },
    filename: {
        type: Sequelize.STRING,
        allowNull: true,
    },
    mimetype: {
        type: Sequelize.STRING,
        allowNull: true,
    },
};

interface PictureAttributes {
    id: number;
    filename: string;
    destination: string;
    mimetype: string;
}
interface PictureCreationAttributes extends Optional<PictureAttributes, "id"> {}

export default class Picture
    extends Sequelize.Model<PictureAttributes, PictureCreationAttributes>
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
