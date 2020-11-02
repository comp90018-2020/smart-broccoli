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

    // Whether calendar is free
    calendarFree: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        allowNull: false,
    },

    // Foreign key constraint
    // https://stackoverflow.com/questions/29551941
    userId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        unique: "unique_state_user",
    },
};

interface UserStateAttributes {
    id: number;
    free: boolean;
    calendarFree: boolean;
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
    public calendarFree: boolean;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
            indexes: [
                {
                    name: "unique_state_user",
                    unique: true,
                    // @ts-ignore
                    fields: [sequelize.col("userId")],
                },
            ],
        });
    }
}
