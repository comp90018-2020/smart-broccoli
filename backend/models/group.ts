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
    code: {
        type: Sequelize.STRING,
        allowNull: true,
    },
};

interface GroupAttributes {
    id?: number;
    name?: string;
    code?: string;
    ownerId?: number;
}
interface GroupCreationAttributes extends Optional<GroupAttributes, "id"> {}
interface GroupInstance
    extends Sequelize.Model<GroupAttributes, GroupCreationAttributes>,
        GroupAttributes {}

export default class Group
    extends Sequelize.Model<GroupAttributes, GroupCreationAttributes>
    implements GroupAttributes {
    public readonly id!: number;
    public readonly ownerId?: number;
    public name?: string;
    public code: string;

    static initialise(sequelize: Sequelize.Sequelize) {
        return sequelize.define<GroupInstance>("UserGroup", schema);
    }
}
