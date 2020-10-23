import { Group, Quiz, User } from "models";
import Sequelize, { Optional } from "sequelize";

// Represents quiz session
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    isGroup: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },
    type: {
        type: Sequelize.ENUM("live", "self paced"),
        allowNull: false,
    },
    code: {
        type: Sequelize.STRING,
        allowNull: true,
    },
    state: {
        type: Sequelize.ENUM("waiting", "active", "ended"),
        allowNull: false,
        defaultValue: "waiting",
    },
    subscribeGroup: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
    },
};

interface SessionAttributes {
    id: number;
    isGroup: boolean;
    subscribeGroup: boolean;
    type: string;
    code: string;
    state: string;

    quizId: number;
    groupId: number;
}
interface SessionCreationAttributes
    extends Optional<SessionAttributes, "id" | "code" | "subscribeGroup"> {}

export default class Session
    extends Sequelize.Model<SessionAttributes, SessionCreationAttributes>
    implements SessionAttributes {
    public readonly id!: number;

    public code: string;
    public subscribeGroup: boolean;

    public readonly type: string;
    public readonly state!: string;
    public readonly isGroup!: boolean;
    public readonly quizId: number;
    public readonly groupId: number;

    public readonly Users?: User[];
    public readonly Group?: Group;
    public readonly Quiz?: Quiz;

    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
            indexes: [
                {
                    name: "unique_session_code",
                    unique: true,
                    fields: [
                        // @ts-ignore
                        sequelize.col("code"),
                    ],
                },
            ],
        });
    }
}
