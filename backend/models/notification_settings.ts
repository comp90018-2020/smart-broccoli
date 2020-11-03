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

    // Whether to notify when there are events on the calendar
    calendarLive: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
    },
    calendarSelfPaced: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },

    // Days of week
    days: {
        type: Sequelize.ARRAY(Sequelize.BOOLEAN),
        allowNull: false,
        defaultValue: [false, true, true, true, true, true, false],
    },
    // Timezone by IANA name
    timezone: {
        type: Sequelize.STRING,
        allowNull: true,
    },

    // Work
    ssid: {
        type: Sequelize.STRING,
        allowNull: true,
    },
    // Location
    location: {
        type: Sequelize.JSONB,
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

// Lat/lon location
interface Location {
    lat: number;
    lon: number;
}

interface NotificationSettingsAttributes {
    id: number;
    userId: number;
    onTheMove: boolean;
    onCommute: boolean;
    calendarLive: boolean;
    calendarSelfPaced: boolean;
    days: boolean[];
    timezone: string;
    ssid: string;
    location: Location;
    radius: number;
    notificationWindow: number;
    maxNotificationsPerDay: number;
}
interface NotificationSettingsCreationAttributes
    extends Optional<
        NotificationSettingsAttributes,
        | "id"
        | "onTheMove"
        | "onCommute"
        | "calendarLive"
        | "calendarSelfPaced"
        | "days"
        | "timezone"
        | "ssid"
        | "location"
        | "radius"
        | "notificationWindow"
        | "maxNotificationsPerDay"
    > {}

export default class NotificationSettings
    extends Sequelize.Model<
        NotificationSettingsAttributes,
        NotificationSettingsCreationAttributes
    >
    implements NotificationSettingsAttributes {
    public readonly id!: number;
    public readonly userId!: number;

    public onTheMove: boolean;
    public onCommute: boolean;
    public calendarLive: boolean;
    public calendarSelfPaced: boolean;
    public days: boolean[];
    public timezone: string;
    public ssid: string;
    public location: Location;
    public radius: number;
    public notificationWindow: number;
    public maxNotificationsPerDay: number;

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
