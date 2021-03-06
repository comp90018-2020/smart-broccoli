import Sequelize, { Optional } from "sequelize";
import User from "./user";

// Stores tokens
// Considerations made:
// https://stackoverflow.com/questions/42763146
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    token: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true,
    },
    scope: {
        type: Sequelize.STRING,
        allowNull: false,
    },
    revoked: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },
};

interface TokenAttributes {
    id: number;
    userId: number;
    token: string;
    scope: string;
    revoked?: boolean;
    createdAt: Date;
    updatedAt: Date;
}
interface TokenCreationAttributes
    extends Optional<TokenAttributes, "id" | "createdAt" | "updatedAt"> {}

export default class Token
    extends Sequelize.Model<TokenAttributes, TokenCreationAttributes>
    implements TokenAttributes {
    public token!: string;
    public scope!: string;
    public revoked!: boolean;

    public readonly id!: number;
    public readonly User?: User;
    public readonly userId!: number;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
            indexes: [
                // Ensure that tokens are unique
                {
                    name: "unique_token",
                    unique: true,
                    // @ts-ignore
                    fields: [sequelize.fn("lower", sequelize.col("token"))],
                },
            ],
        });
    }
}
