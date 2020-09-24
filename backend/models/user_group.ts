import Sequelize, { Optional } from "sequelize";

// User/Group associations
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    type: {
        type: Sequelize.ENUM("creator", "member"),
        defaultValue: "member",
        allowNull: false,
    },
};

interface UserGroupAttributes {
    id: number;
    type?: string;
}
interface UserGroupCreationAttributes
    extends Optional<UserGroupAttributes, "id"> {}
interface UserGroupInstance
    extends Sequelize.Model<UserGroupAttributes, UserGroupCreationAttributes>,
        UserGroupAttributes {}

export default class UserGroup
    extends Sequelize.Model<UserGroupAttributes, UserGroupCreationAttributes>
    implements UserGroupAttributes {
    public readonly id!: number;
    public readonly type?: string;

    static initialise(sequelize: Sequelize.Sequelize) {
        return sequelize.define<UserGroupInstance>("UserGroup", schema);
    }
}
