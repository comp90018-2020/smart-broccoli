import { Group } from "models";
import Sequelize, { Optional } from "sequelize";
import User from "./user";

// User/Group associations
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    role: {
        type: Sequelize.ENUM("owner", "member"),
        defaultValue: "member",
        allowNull: false,
    },
};

interface UserGroupAttributes {
    id: number;
    role: string;
    userId: number;
    groupId: number;
    Group?: Group;
    User?: User;
}
interface UserGroupCreationAttributes
    extends Optional<UserGroupAttributes, "id"> {}

export default class UserGroup
    extends Sequelize.Model<UserGroupAttributes, UserGroupCreationAttributes>
    implements UserGroupAttributes {
    public readonly id!: number;
    public role: string;
    public readonly userId: number;
    public readonly groupId: number;

    public Group?: Group;
    public User?: User;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
