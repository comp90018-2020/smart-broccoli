import Sequelize, { Optional } from "sequelize";

// User/Group associations
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    type: {
        type: Sequelize.ENUM("owner", "member"),
        defaultValue: "member",
        allowNull: false,
    },
};

interface UserGroupAttributes {
    id: number;
    type: string;
    userId: number;
    groupId: number;
}
interface UserGroupCreationAttributes
    extends Optional<UserGroupAttributes, "id"> {}

export default class UserGroup
    extends Sequelize.Model<UserGroupAttributes, UserGroupCreationAttributes>
    implements UserGroupAttributes {
    public readonly id!: number;
    public type: string;
    public readonly userId: number;
    public readonly groupId: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
