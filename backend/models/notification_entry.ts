import { timeStamp } from "console";
import Sequelize, { Optional } from "sequelize";

const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    time: {
        type: Sequelize.DATE,
        allowNull: false,
    },
};

interface NotificationAttributes {
    id: number;
    time: Date;
    userId: number;
    createdAt: Date;
    updatedAt: Date;
}
interface NotificationCreationAttributes
    extends Optional<
        NotificationAttributes,
        "id" | "createdAt" | "updatedAt"
    > {}

export default class NotificationEntry
    extends Sequelize.Model<
        NotificationAttributes,
        NotificationCreationAttributes
    >
    implements NotificationAttributes {
    public readonly id!: number;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;

    public readonly time!: Date;
    public readonly userId!: number;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
