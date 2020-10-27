// Database initialisation
import Sequelize from "sequelize";

// Import models
import User from "./user";
import Token from "./token";
import Picture from "./picture";
import Quiz from "./quiz";
import Question from "./question";
import Group from "./group";
import UserGroup from "./user_group";
import Session from "./session";
import SessionParticipant from "./session_participant";
import NotificationSettings from "./notification_settings";
import UserState from "./notification_user_state";

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
Question.initialise(sequelize);
Quiz.initialise(sequelize);
Group.initialise(sequelize);
UserGroup.initialise(sequelize);
Session.initialise(sequelize);
SessionParticipant.initialise(sequelize);
NotificationSettings.initialise(sequelize);
UserState.initialise(sequelize);

// User has many tokens
User.hasMany(Token, { as: "tokens", foreignKey: "userId" });
Token.belongsTo(User, { foreignKey: "userId" });
// User has profile picture
User.belongsTo(Picture, {
    foreignKey: "pictureId",
    onDelete: "set null",
});
// User has notification settings
User.hasOne(NotificationSettings, { foreignKey: "userId" });
// User has state
User.hasOne(UserState, { foreignKey: "userId" });

// Quiz has picture
Quiz.belongsTo(Picture, {
    foreignKey: "pictureId",
    onDelete: "set null",
});
// Quiz has many questions
Quiz.hasMany(Question, {
    as: "questions",
    foreignKey: "quizId",
    onDelete: "cascade",
});
// Question has picture
Question.belongsTo(Picture, {
    foreignKey: "pictureId",
    onDelete: "set null",
});
// Quiz belongs to group
Quiz.belongsTo(Group, {
    foreignKey: "groupId",
    onDelete: "cascade",
});
Group.hasMany(Quiz, {
    foreignKey: "groupId",
});

// Users and groups are associated
// @ts-ignore
Group.belongsToMany(User, { through: UserGroup, foreignKey: "groupId" });
// @ts-ignore
User.belongsToMany(Group, { through: UserGroup, foreignKey: "userId" });

// Quiz session
Quiz.hasMany(Session, { foreignKey: "quizId" });
Session.belongsTo(Quiz, { foreignKey: "quizId" });

// Sessions and users are associated
User.belongsToMany(Session, {
    // @ts-ignore
    through: SessionParticipant,
    foreignKey: "userId",
});
Session.belongsToMany(User, {
    // @ts-ignore
    through: SessionParticipant,
    foreignKey: "sessionId",
});

Session.belongsTo(Group, {
    foreignKey: "groupId",
});

export default sequelize;
export {
    User,
    Token,
    UserGroup,
    Group,
    Question,
    Quiz,
    Picture,
    Session,
    SessionParticipant,
    NotificationSettings,
    UserState,
};
