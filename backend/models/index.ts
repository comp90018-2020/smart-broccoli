// Database initialisation
import Sequelize from "sequelize";

// Import models
import User from "./user";
import Token from "./token";
import Picture from "./picture";
import Quiz from "./quiz";
import Question from "./question";
import QuestionOption from "./question_option";

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
QuestionOption.initialise(sequelize);
Question.initialise(sequelize);
Quiz.initialise(sequelize);

// User has many tokens
User.hasMany(Token, { as: "tokens", foreignKey: "userId" });
Token.belongsTo(User, { foreignKey: "userId" });
// User has profile picture
User.belongsTo(Picture, {
    foreignKey: "pictureId",
    onDelete: "set null",
});

// Question has QuestionOptions
Question.hasMany(QuestionOption, { as: "options", foreignKey: "questionId" });
// Quiz has many questions
Quiz.hasMany(Question, {
    as: "questions",
    foreignKey: "quizId",
    onDelete: "cascade",
});
// User has many quizzes
User.hasMany(Quiz, {
    as: "quizzes",
    foreignKey: "userId",
    onDelete: "cascade",
});

export default sequelize;
export { User, Token, Question, Quiz, QuestionOption };
