import Sequelize, { Optional } from "sequelize";

// User's state (used to determine notification sending)
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },

    // Course location
    location: {
        type: Sequelize.GEOMETRY("POINT"),
        allowNull: true,
    },
    // Number of devices which are around
    numDevices: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
        allowNull: false,
    },

    // Whether calendar is free
    calendarFree: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        allowNull: false,
    },
    // General free
    free: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        allowNull: false,
    },
};

interface UserStateAttributes {
    id: number;
}
interface UserStateCreationAttributes
    extends Optional<UserStateAttributes, "id"> {}

export default class UserGroup
    extends Sequelize.Model<UserStateAttributes, UserStateCreationAttributes>
    implements UserStateAttributes {
    public readonly id!: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
