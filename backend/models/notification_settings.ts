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
        defaultValue: false,
    },
    onCommute: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },

    // Whether calendar should be checked
    calendar: {
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
    // Timezone by IANA name
    timeZone: {
        type: Sequelize.STRING,
        allowNull: false,
    },

    // Work
    ssid: {
        type: Sequelize.STRING,
        allowNull: true,
    },
    // Location
    location: {
        type: Sequelize.GEOMETRY("POINT"),
        allowNull: true,
    },
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
        defaultValue: 0,
    },
    // Max. number of notifications per day
    maxNotificationsPerDay: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
    },
};

interface NotificationSettingsAttributes {
    id?: number;
    userId?: number;
}
interface NotificationSettingsCreationAttributes
    extends Optional<NotificationSettingsAttributes, "id"> {}

export default class NotificationSettings
    extends Sequelize.Model<
        NotificationSettingsAttributes,
        NotificationSettingsCreationAttributes
    >
    implements NotificationSettingsAttributes {
    public readonly id!: number;
    public readonly userId!: number;

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
