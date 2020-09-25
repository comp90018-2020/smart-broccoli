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
};

interface GroupAttributes {
    id?: number;
    name: string;
    userGroups?: UserGroup[];
    Users?: User[];
}
interface GroupCreationAttributes extends Optional<GroupAttributes, "id"> {}

export default class Group
    extends Sequelize.Model<GroupAttributes, GroupCreationAttributes>
    implements GroupAttributes {
    public readonly id!: number;
    public readonly userGroups?: UserGroup[];
    public name: string;
    public Users?: User[];

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
