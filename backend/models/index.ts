// Database initialisation
import Sequelize from "sequelize";

// Import models
import User from "./user";
import Token from "./token";
import Picture from "./picture";

// Initiate sequelize instance
const sequelize: Sequelize.Sequelize = new Sequelize.Sequelize(
    process.env.POSTGRES_DB,
    process.env.POSTGRES_USER,
    process.env.POSTGRES_PASSWORD,
    {
        host: process.env.POSTGRES_HOST,
        dialect: "postgres",
        logging: process.env.NODE_ENV === "development",
    }
);

// Init models
Picture.initialise(sequelize);
User.initialise(sequelize);
Token.initialise(sequelize);

// User has many tokens
User.hasMany(Token, { as: "tokens", foreignKey: "userId" });
Token.belongsTo(User, { foreignKey: "userId" });

User.belongsTo(Picture, {
    foreignKey: "pictureId",
    onDelete: "set null",
});

export default sequelize;
export { User, Token };
