import * as authController from "../controllers/auth";
import * as groupController from "../controllers/group";
import * as quizController from "../controllers/quiz";
import axios from "axios";
import formData from "form-data";
import sequelize, { Group } from "../models";
import fs from "fs";
import path from "path";

/**
 * The script generates 10 users, 10 groups, 2 quizzes that are filled, and 8 quizzes that are empty.
 * 2 filled quizzes are within the "Fine Arts" group that is joined by all users.
 * The script starts with completely erasing the database.

 * To see quiz creator login under haydon@gmail.com and look for quizzes Painting and Sculpture
 * TO see quiz taker login under shawn@gmail.com and look for quizzes Painting and Sculpture
 */

const PICTURE_DIRECTORY = "demo_pictures/";

interface CustomQuiz {
    name: string;
    imgUrl: string;
    questions?: CustomMCQQuestion[];
}
interface CustomMCQAnswer {
    correct: boolean;
    text: string;
}
interface CustomMCQQuestion {
    question: string;
    imgUrl: string;
    answers: CustomMCQAnswer[];
}

const QUIZ_TYPE = ["live", "self paced"];

const QUESTIONS_PAINTING: CustomMCQQuestion[] = [
    {
        question:
            "The Birth of Venus is considered to be one of the top 10 paintings of all time. Who made it?",
        imgUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Botticelli_Venus.jpg/512px-Botticelli_Venus.jpg",
        answers: [
            { correct: true, text: "Sandro Botticelli" },
            { correct: false, text: "Claude Monet" },
            { correct: false, text: "Rembrandt van Rijn" },
            { correct: false, text: "Edvard Munch" },
        ],
    },
    {
        question:
            "Which famous painting is also referred to as The Dutch Monalisa",
        imgUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Girl_with_a_Pearl_Earring.jpg/512px-Girl_with_a_Pearl_Earring.jpg",
        answers: [
            { correct: true, text: "Girl with a Pearl Earring" },
            { correct: false, text: "Guernica" },
            { correct: false, text: "Night Watch" },
            { correct: false, text: "Dutch Mona Lisa" },
        ],
    },
    {
        question:
            "Guernica is one of Pablo Piccaso's famous paintings. In which year did he complete it?",
        imgUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Mural_del_Gernika.jpg/512px-Mural_del_Gernika.jpg",
        answers: [
            { correct: true, text: "1937" },
            { correct: false, text: "1934" },
            { correct: false, text: "1935" },
            { correct: false, text: "1936" },
        ],
    },
    {
        question: "Where would you find the painting The Last Supper",
        imgUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Leonardo_da_Vinci_%281452-1519%29_-_The_Last_Supper_%281495-1498%29.jpg/512px-Leonardo_da_Vinci_%281452-1519%29_-_The_Last_Supper_%281495-1498%29.jpg",
        answers: [
            { correct: true, text: "Milan" },
            { correct: false, text: "Venice" },
            { correct: false, text: "Rome" },
            { correct: false, text: "Naples" },
        ],
    },
];
const QUESTIONS_SCULPTURE: CustomMCQQuestion[] = [
    {
        question: "What can you infer about prehistoric sculpture?",
        imgUrl:
            "https://upload.wikimedia.org/wikipedia/commons/8/80/Huittisten_hirvenp%C3%A4%C3%A4.jpg",
        answers: [
            { correct: true, text: "It usually depicted animals and humans" },
            { correct: false, text: "It usually depicted landscapes" },
            {
                correct: false,
                text: "It usually depicted imaginary, mythical creatures",
            },
            { correct: false, text: "It usually depicted abstract forms" },
        ],
    },
    {
        question:
            "Which term best describes Michelangelo's sculpture of David?",
        imgUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/%27David%27_by_Michelangelo_Fir_JBU002.jpg/320px-%27David%27_by_Michelangelo_Fir_JBU002.jpg",
        answers: [
            { correct: true, text: "Realistic" },
            { correct: false, text: "Two-dimensional" },
            { correct: false, text: "Exaggerated" },
            { correct: false, text: "Abstract" },
        ],
    },
    {
        question:
            "Tim's walking around a sculpture to get a good look at its back. What style of sculpture must it be?",
        imgUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Wood_Bodhisattva.jpg/640px-Wood_Bodhisattva.jpg",
        answers: [
            { correct: true, text: "In the round" },
            { correct: false, text: "Prehistoric" },
            { correct: false, text: "Relief" },
            { correct: false, text: "Monumental" },
        ],
    },
    {
        question: "Which of the following is a true statement about busts?",
        imgUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Bust_of_a_Man_by_the_studio_of_Francis_Harwood.jpg/360px-Bust_of_a_Man_by_the_studio_of_Francis_Harwood.jpg",
        answers: [
            { correct: true, text: "They never include legs" },
            { correct: false, text: "They only depict famous people" },
            {
                correct: false,
                text: "They are the most common form of sculpture",
            },
            { correct: false, text: "They cannot be made out of clay" },
        ],
    },
];
const QUIZ_NAMES_FINE_ARTS: CustomQuiz[] = [
    {
        name: "Painting",
        imgUrl: "https://unsplash.com/photos/1rBg5YSi00c",
        questions: QUESTIONS_PAINTING,
    },
    {
        name: "Sculpture",
        imgUrl: "https://unsplash.com/photos/AUgTvvQxDhg",
        questions: QUESTIONS_SCULPTURE,
    },
    { name: "Mosaics", imgUrl: "https://unsplash.com/photos/jy4oF77LQmM" },
    { name: "Music", imgUrl: "https://unsplash.com/photos/laHwVPkMTzY" },
    { name: "Poetry", imgUrl: "https://unsplash.com/photos/FDzRG30DeVM" },
];
const QUIZ_NAMES_MANAGEMENT: CustomQuiz[] = [
    {
        name: "Human Resource Fundamentals",
        imgUrl: "https://unsplash.com/photos/DsCfl94sWz4",
    },
    {
        name: "Managerial Economics",
        imgUrl: "https://unsplash.com/photos/OtfnlTw0lH4",
    },
    {
        name: "Managing People",
        imgUrl: "https://unsplash.com/photos/fznQW-kn5VU",
    },
    {
        name: "Managerial Psychology",
        imgUrl: "https://unsplash.com/photos/cAQZuqdvba8",
    },
    {
        name: "Business Analysis & Decision Making",
        imgUrl: "https://unsplash.com/photos/J3AV8F-B42M",
    },
];

const NAMES = [
    "Haydon Holding",
    "Jamie Taylor",
    "Shawn Lee",
    "Leslie Guevara",
    "Cameron Bean",
    "Billie Berger",
    "Elliott Paul",
    "Emerson Craig",
    "Kai Rojas",
    "Riley Wormald",
];

const GROUP_NAMES = [
    [
        "Fine Arts",
        "Architecture",
        "Art History",
        "Design",
        "Film Studies",
        "Graphic Design",
    ],
    [
        "Management",
        "Accounting",
        "Entrepreneurship",
        "Finance",
        "Marketing",
        "Negotiations",
    ],
];

const PROFILE_PICTURES = [
    "https://unsplash.com/photos/XHVpWcr5grQ",
    "https://unsplash.com/photos/dcZsxUAAJXs",
    "https://unsplash.com/photos/TMgQMXoglsM",
    "https://unsplash.com/photos/J1OScm_uHUQ",
    "https://unsplash.com/photos/kVg2DQTAK7c",
    "https://unsplash.com/photos/3402kvtHhOo",
    "https://unsplash.com/photos/OeXcIHFwtsM",
    "https://unsplash.com/photos/7omHUGhhmZ0",
    "https://unsplash.com/photos/sibVwORYqs0",
    "https://unsplash.com/photos/ger61_TX6oI",
];

const PASSWORD = "12345678";
const EMAIL_HOST = "@gmail.com";

export const generateDemoData = async () => {
    console.log("[*] Generating demo data");

    // Reset database
    await sequelize.sync({ force: true });

    // Download pictures
    const pictures = await downloadPictures();

    const users: {
        id: number;
        token: string;
        name: string;
        email: string;
        groupsCreated: Group[];
    }[] = [];
    for (const [index, name] of NAMES.entries()) {
        // Register
        const userRegister = await authController.register({
            email: `${name.split(" ")[0].toLowerCase()}${EMAIL_HOST}`,
            password: PASSWORD,
            name: name,
        });

        // Login
        const userLogin = await authController.login(
            userRegister.email,
            PASSWORD
        );
        users.push({
            id: userLogin.id,
            token: userLogin.token,
            name: userRegister.name,
            email: userRegister.email,
            groupsCreated: [],
        });

        // Upload picture
        uploadProfilePicture(
            pictures,
            userLogin.token,
            PROFILE_PICTURES[index]
        );
    }

    // Generating groups for two members
    for (const [userIndex, user] of users.entries()) {
        for (const [groupIndex, groups] of GROUP_NAMES.entries()) {
            if (userIndex === groupIndex)
                for (const group of groups) {
                    // Creator
                    users[userIndex].groupsCreated.push(
                        await groupController.createGroup(user.id, group)
                    );
                }
        }
    }
    // Join groups
    for (const [userIndex, user] of users.entries()) {
        for (const [groupIndex, groups] of GROUP_NAMES.entries()) {
            if (userIndex !== groupIndex)
                for (const group of groups) {
                    // Member
                    await groupController.joinGroup(user.id, { name: group });
                }
        }
    }

    // Quiz generation for arts
    for (const [i, quiz] of QUIZ_NAMES_FINE_ARTS.entries()) {
        await generateQuiz(pictures, users[0], users[0].groupsCreated[0].id, {
            name: quiz.name,
            type: QUIZ_TYPE[i % 2],
            imgUrl: quiz.imgUrl,
            // Has questions, process questions, otherwise empty
            questions: quiz.questions
                ? generateQuestionArray(quiz.questions)
                : [],
        });
    }
    // Quiz generation for business
    for (const [i, quiz] of QUIZ_NAMES_MANAGEMENT.entries()) {
        await generateQuiz(pictures, users[1], users[1].groupsCreated[0].id, {
            name: quiz.name,
            type: QUIZ_TYPE[i % 2],
            imgUrl: quiz.imgUrl,
            questions: [],
        });
    }

    console.log("[*] Finished generating demo data");
};

/// Generates questions from question defined in this file
const generateQuestionArray = (questions: CustomMCQQuestion[]): any => {
    return questions.map((question) => {
        return {
            text: question.question,
            type: "choice",
            options: question.answers,
            imgUrl: question.imgUrl,
        };
    });
};

// Creates and uploads quiz/questions and pictures
async function generateQuiz(
    pictures: Map<string, string>,
    user: any,
    groupId: number,
    quizInfo: {
        questions: any;
        name: string;
        type: string;
        imgUrl: string;
    }
) {
    // Create quiz
    const quiz = await quizController.createQuiz(user.id, {
        groupId: groupId,
        type: quizInfo.type,
        title: quizInfo.name,
        timeLimit: 10,
        questions: quizInfo.questions,
    });
    // Upload quiz picture
    uploadQuizPicture(pictures, user, quiz.id, quizInfo.imgUrl);

    // Upload question pictures
    for (const [index, question] of quiz.questions.entries()) {
        uploadQuestionPicture(
            pictures,
            user,
            quiz.id,
            quizInfo.questions[index].imgUrl,
            question.id
        );
    }
}

// Downloads all requires pictures
const downloadPictures = async () => {
    // All the pictures
    const allPictures = [
        ...QUESTIONS_PAINTING.map((q) => q.imgUrl),
        ...QUESTIONS_SCULPTURE.map((q) => q.imgUrl),
        ...QUIZ_NAMES_MANAGEMENT.map((q) => q.imgUrl),
        ...QUIZ_NAMES_FINE_ARTS.map((q) => q.imgUrl),
        ...PROFILE_PICTURES,
    ];
    // Give unique filenames
    const filename = (url: string): string => {
        const urlSplit = url.split("/");
        return urlSplit[urlSplit.length - 1];
    };
    const filenameMap = new Map(allPictures.map((url) => [url, filename(url)]));

    // Make picture directory
    await mkdirp(PICTURE_DIRECTORY);

    // Download
    for (const picture of allPictures) {
        await downloadPicture(picture, filenameMap.get(picture));
    }
    return filenameMap;
};

// Downloads a picture into path
const downloadPicture = async (url: string, picturePath: string) => {
    const completePath = path.join(PICTURE_DIRECTORY, picturePath);
    if (fs.existsSync(completePath)) return completePath;
    const response = await axios.get(
        url.includes("unsplash") ? `${url}/download?force=true` : url,
        { responseType: "stream" }
    );
    response.data.pipe(fs.createWriteStream(completePath));
};

// mkdir -p
const mkdirp = (path: string) => {
    return new Promise((resolve, reject) => {
        fs.mkdir(path, { recursive: true }, (err) => {
            if (err) return reject(err);
            return resolve();
        });
    });
};

// Makes http request to upload quiz picture
async function uploadQuizPicture(
    pictureMap: Map<string, string>,
    user: any,
    quizId: number,
    imgUrl: string
) {
    const form = new formData();
    form.append(
        "picture",
        fs.readFileSync(path.join(PICTURE_DIRECTORY, pictureMap.get(imgUrl))),
        { filename: imgUrl }
    );

    const formHeaders = form.getHeaders();
    try {
        await axios.put(
            "http://localhost:3000/quiz/" + quizId + "/picture",
            form,
            {
                headers: {
                    ...formHeaders,
                    authorization: "Bearer " + user.token,
                },
            }
        );
    } catch (err) {
        console.error(imgUrl);
        console.error(err);
        process.exit(1);
    }
}

// Makes http request to upload question picture
async function uploadQuestionPicture(
    pictureMap: Map<string, string>,
    user: any,
    quizId: number,
    imgUrl: string,
    questionId: string
) {
    const form = new formData();
    form.append(
        "picture",
        fs.readFileSync(path.join(PICTURE_DIRECTORY, pictureMap.get(imgUrl))),
        { filename: imgUrl }
    );

    const formHeaders = form.getHeaders();
    try {
        axios.put(
            "http://localhost:3000/quiz/" +
                quizId +
                "/question/" +
                questionId +
                "/picture",
            form,
            {
                headers: {
                    ...formHeaders,
                    authorization: "Bearer " + user.token,
                },
            }
        );
    } catch (err) {
        console.error(imgUrl);
        console.error(err);
        process.exit(1);
    }
}

// Makes http request to upload profile picture
async function uploadProfilePicture(
    pictureMap: Map<string, string>,
    userToken: any,
    imgUrl: string
) {
    const form = new formData();
    form.append(
        "avatar",
        fs.readFileSync(path.join(PICTURE_DIRECTORY, pictureMap.get(imgUrl))),
        { filename: imgUrl }
    );

    const formHeaders = form.getHeaders();
    try {
        await axios.put("http://localhost:3000/user/profile/picture", form, {
            headers: {
                ...formHeaders,
                authorization: "Bearer " + userToken,
            },
        });
    } catch (err) {
        console.error(imgUrl);
        console.error(err);
        process.exit(1);
    }
}
