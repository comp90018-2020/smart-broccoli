import Sequelize, { Optional } from "sequelize";

// Represents groups of users
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: Sequelize.STRING,
        allowNull: true,
    },
};

interface GroupAttributes {
    id?: number;
    name?: string;
}
interface GroupCreationAttributes extends Optional<GroupAttributes, "id"> {}

export default class Group
    extends Sequelize.Model<GroupAttributes, GroupCreationAttributes>
    implements GroupAttributes {
    public readonly id!: number;
    public name?: string;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
