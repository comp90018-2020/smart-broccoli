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
