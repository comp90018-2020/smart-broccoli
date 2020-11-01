import Sequelize, { Optional } from "sequelize";

// User's notification settings
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },

    // Foreign key constraint
    // https://stackoverflow.com/questions/29551941
    userId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        unique: "unique_settings_user",
    },

    // On the move settings
    onTheMove: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
    },
    onPublicTransport: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
    },
    publicTransportDevices: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 10,
    },
    inVehicle: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },

    // Whether calendar should be checked
    checkCalendar: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
    },

    // Days of week
    days: {
        type: Sequelize.ARRAY(Sequelize.BOOLEAN),
        allowNull: false,
        defaultValue: [false, true, true, true, true, true, false],
    },
    timeZone: {
        type: Sequelize.STRING,
        allowNull: false,
    },

    // Do not notify while app is open
    apps: {
        type: Sequelize.ARRAY(Sequelize.STRING),
        allowNull: true,
    },

    // Location (todo)

    // Radius in km
    radius: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 5,
    },

    // Minimum time between notifications
    notificationWindow: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 30,
    },
    // Max. number of notifications per day
    maxNotificationPerDay: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 5,
    },
};

interface SmartQuizOptionsAttributes {
    id?: number;
}
interface SmartQuizOptionsCreationAttributes
    extends Optional<SmartQuizOptionsAttributes, "id"> {}

export default class SmartQuizOptions
    extends Sequelize.Model<
        SmartQuizOptionsAttributes,
        SmartQuizOptionsCreationAttributes
    >
    implements SmartQuizOptionsAttributes {
    public readonly id!: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
            indexes: [
                {
                    name: "unique_settings_user",
                    unique: true,
                    // @ts-ignore
                    fields: [sequelize.col("userId")],
                },
            ],
        });
    }
}
