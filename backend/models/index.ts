// Database initialisation
import Sequelize from "sequelize";

// Import models
import User from "./user";
import Token from "./token";
import Picture from "./picture";
import Group from "./group";
import UserGroup from "./user_group";

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
UserGroup.initialise(sequelize);
Group.initialise(sequelize);

// User has many tokens
User.hasMany(Token, { as: "tokens", foreignKey: "userId" });
Token.belongsTo(User, { foreignKey: "userId" });
// User has picture
User.belongsTo(Picture, {
    foreignKey: "pictureId",
    onDelete: "set null",
});

Group.belongsToMany(User, { through: typeof UserGroup });
User.belongsToMany(Group, { through: typeof UserGroup });

export default sequelize;
export { User, Token, UserGroup, Group };
