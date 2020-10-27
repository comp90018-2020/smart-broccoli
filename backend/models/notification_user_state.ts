import Sequelize, { Optional } from "sequelize";

// User's state (used to determine notification sending)
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },

    // Free, or not free
    free: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        allowNull: false,
    },
};

interface UserStateAttributes {
    id: number;
    free: boolean;
    userId: number;
}
interface UserStateCreationAttributes
    extends Optional<UserStateAttributes, "id"> {}

export default class UserState
    extends Sequelize.Model<UserStateAttributes, UserStateCreationAttributes>
    implements UserStateAttributes {
    public readonly id!: number;
    public readonly userId!: number;
    public free: boolean;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
