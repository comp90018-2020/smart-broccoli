import { Quiz, UserGroup } from "models";
import Sequelize, {
    BelongsToGetAssociationMixin,
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
    code: {
        type: Sequelize.STRING,
        allowNull: true,
    },
};

interface GroupAttributes {
    id?: number;
    name: string;
    defaultGroup: boolean;
    code: string;
    Users?: User[];
    UserGroup?: UserGroup;
}
interface GroupCreationAttributes
    extends Optional<GroupAttributes, "id" | "defaultGroup" | "code"> {}

export default class Group
    extends Sequelize.Model<GroupAttributes, GroupCreationAttributes>
    implements GroupAttributes {
    public readonly id!: number;
    public name: string;
    public readonly defaultGroup: boolean;
    public code: string;
    public Users?: User[];
    public UserGroup?: UserGroup;

    public getUsers!: BelongsToManyGetAssociationsMixin<User>;
    public getQuizzes!: HasManyGetAssociationsMixin<Quiz>;

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
