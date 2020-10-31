import { Session } from "inspector";
import { User } from "models";
import Sequelize, { Optional } from "sequelize";

// Session/User associations
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    role: {
        type: Sequelize.ENUM("host", "participant"),
        defaultValue: "participant",
        allowNull: false,
    },
    state: {
        type: Sequelize.ENUM("joined", "complete", "left", "lost"),
        allowNull: false,
        defaultValue: "joined",
    },
    progress: {
        type: Sequelize.JSON,
        allowNull: true,
    },
};

interface SessionParticipantAttributes {
    id: number;
    role: string;
    state: string;
    progress?: object;
    userId: number;
    sessionId: number;
}
interface SessionParticipantCreationAttributes
    extends Optional<SessionParticipantAttributes, "id" | "state"> {}

export default class SessionParticipant
    extends Sequelize.Model<
        SessionParticipantAttributes,
        SessionParticipantCreationAttributes
    >
    implements SessionParticipantAttributes {
    public readonly id!: number;
    public role: string;
    public state: string;
    public readonly userId: number;
    public readonly sessionId: number;
    public progress: object;

    public Session?: Session;
    public User?: User;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
        });
    }
}
