import { UserGroup } from "models";
import Sequelize, {
    BelongsToManyGetAssociationsMixin,
    HasManyGetAssociationsMixin,
    Optional,
} from "sequelize";
import User from "./user";

// Represents groups of users
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: Sequelize.STRING,
        allowNull: false,
    },
    defaultGroup: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },
};

interface GroupAttributes {
    id?: number;
    name: string;
    defaultGroup: boolean;
    Users?: User[];
    UserGroup?: UserGroup;
}
interface GroupCreationAttributes
    extends Optional<GroupAttributes, "id" | "defaultGroup"> {}

export default class Group
    extends Sequelize.Model<GroupAttributes, GroupCreationAttributes>
    implements GroupAttributes {
    public readonly id!: number;
    public name: string;
    public readonly defaultGroup: boolean;
    public Users?: User[];
    public UserGroup?: UserGroup;

    public getUsers!: BelongsToManyGetAssociationsMixin<User>;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
            indexes: [
                {
                    name: "unique_name",
                    unique: true,
                    // @ts-ignore
                    fields: [sequelize.fn("lower", sequelize.col("name"))],
                },
            ],
        });
    }
}
