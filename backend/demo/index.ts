import * as authController from "../controllers/auth";
import * as groupController from "../controllers/group";
import * as quizController from "../controllers/quiz";
import axios from "axios";
import formData from "form-data";
import { OptionAttributes } from "../models/question";
import rebuild from "../tests/rebuild";
import { Group } from "models";

/**
 * The script generates 10 users, 10 groups, 2 quizzes that are filled, and 8 quizzes that are empty.
 * 2 filled quizzes are within the "Fine Arts" group that is joined by all users.
 * The script starts with completely erasing the database.

 * To see quiz creator login under haydon@gmail.com and look for quizes Painting and Sculpture
 * TO sse quiz taker login under shawn@gmail.com and look for quizes Painting and Sculpture
 */

/* Question Assets */
class TempQuestion {
    text: string;
    type: string;
    tf: boolean;
    options: OptionAttributes[];
    imgUrl?: string;
}

const QUIZ_TYPE = ["live", "self paced"];
const QUIZ_NAMES_FINE_ARTS = [
    { name: "Painting", imgUrl: "https://unsplash.com/photos/1rBg5YSi00c" },
    { name: "Sculpture", imgUrl: "https://unsplash.com/photos/AUgTvvQxDhg" },
    { name: "Mosaics", imgUrl: "https://unsplash.com/photos/jy4oF77LQmM" },
    { name: "Music", imgUrl: "https://unsplash.com/photos/laHwVPkMTzY" },
    { name: "Poetry", imgUrl: "https://unsplash.com/photos/FDzRG30DeVM" },
];
const QUIZ_NAMES_MANAGEMENT = [
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

const QUESTIONS_PAINTING = [
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
const QUESTIONs_SCULPTURE = [
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
    // Reset database
    await rebuild();

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
            email: `${name.split(" ")[0].toLowerCase}${EMAIL_HOST}`,
            password: PASSWORD,
            name: name,
        });

        // Login
        const userLogin = await authController.login(
            userRegister.email,
            PASSWORD
        );
        const user: any = {
            id: userLogin.id,
            token: userLogin.token,
            name: userRegister.name,
            email: userRegister.email,
            groupsCreated: [],
        };
        users.push(user);

        // Upload picture
        // uploadProfilePicture(userLogin.token, PROFILE_PICTURES[index]);
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

    // // Generation of genuine quizes
    // let questionArray = await questionDataGen(QUESTIONS_PAINTING);
    // await quizDataGen(
    //     users[0],
    //     users[0].groupsCreated[0].id,
    //     questionArray,
    //     QUIZ_NAMES_FINE_ARTS[0],
    //     QUIZ_TYPE[0]
    // );
    // questionArray = await questionDataGen(QUESTIONs_SCULPTURE);
    // await quizDataGen(
    //     users[0],
    //     users[0].groupsCreated[0].id,
    //     questionArray,
    //     QUIZ_NAMES_FINE_ARTS[1],
    //     QUIZ_TYPE[1]
    // );

    // // Generation of dummy quizzes for arts
    // for (let i = 2; i < QUIZ_NAMES_FINE_ARTS.length; i++) {
    //     await quizDataGen(
    //         users[0],
    //         users[0].groupsCreated[0].id,
    //         [],
    //         QUIZ_NAMES_FINE_ARTS[i],
    //         QUIZ_TYPE[i % 2]
    //     );
    // }

    // // Generation of dummy quizzes for business
    // for (let i = 0; i < QUIZ_NAMES_MANAGEMENT.length; i++) {
    //     await quizDataGen(
    //         users[1],
    //         users[1].groupsCreated[0].id,
    //         [],
    //         QUIZ_NAMES_MANAGEMENT[i],
    //         QUIZ_TYPE[i % 2]
    //     );
    // }
};

// Users join all groups that were not created by themselves
async function generateGroupsForUsers(usersAndGroupNames: any[]) {
    for (let i = 0; i < usersAndGroupNames.length; i++) {
        for (let j = 0; j < usersAndGroupNames[i].groupNames.length; j++) {
            const group = await groupController.createGroup(
                usersAndGroupNames[i].user.id,
                usersAndGroupNames[i].groupNames[j],
                false
            );
            usersAndGroupNames[i].user.groupsCreated.push(group);
        }
    }
}

async function joinGroups(users: any[]) {
    const allGroupsNames = [];
    for (let i = 0; i < users.length; i++) {
        if (users[i].groupsCreated != null) {
            for (let j = 0; j < users[i].groupsCreated.length; j++) {
                allGroupsNames.push(users[i].groupsCreated[j].name);
            }
        }
    }

    for (let i = 0; i < users.length; i++) {
        const userId = users[i].id;
        for (let e = 0; e < allGroupsNames.length; e++) {
            const groupName = allGroupsNames[e];

            let isOwner = false;
            if (users[i].groupsCreated != null) {
                for (let j = 0; j < users[i].groupsCreated.length; j++) {
                    const createdGroupName = users[i].groupsCreated[j].name;
                    if (createdGroupName == groupName) {
                        isOwner = true;
                    }
                }
            }
            if (isOwner == false) {
                const result = await groupController.joinGroup(userId, {
                    name: groupName,
                });
            }
        }
    }
}

// Questions generated only by the first user
async function questionDataGen(questionsNotobject: any[]) {
    const questionsObjectArray: TempQuestion[] = [];

    for (let i = 0; i < questionsNotobject.length; i++) {
        const qN = questionsNotobject[i];
        const question = new TempQuestion();
        question.text = qN.question;
        question.imgUrl = qN.imgUrl;
        question.type = "choice";
        question.tf = false;
        question.options = [];
        for (let e = 0; e < qN.answers.length; e++) {
            const answer = qN.answers[e];
            question.options.push(answer);
        }
        questionsObjectArray.push(question);
    }
    return questionsObjectArray;
}

async function quizDataGen(
    user: any,
    groupId: number[][],
    questions: TempQuestion[],
    quizInfo: any,
    quizType: string
) {
    const quiz = await quizController.createQuiz(user.id, {
        groupId: groupId,
        type: quizType,
        title: quizInfo.name,
        timeLimit: 10,
        questions: questions,
    });
    // uploadQuizPicture(user, quiz.id, quizInfo.imgUrl);

    // for (let j = 0; j < quiz.questions.length; j++) {
    //     uploadQuestionPicture(
    //         user,
    //         quiz.id,
    //         questions[j].imgUrl,
    //         quiz.questions[j].id
    //     );
    // }
}

// async function uploadQuizPicture(user: any, quizId: number, imgUrl: string) {
//     imgUrl = imgUrl + "/download?force=true";
//     console.log(imgUrl);
//     const responseUnsplash = await axios({
//         url: imgUrl,
//         method: "GET",
//         responseType: "stream",
//     });
//     const form = new formData();
//     form.append("picture", responseUnsplash.data);
//     const formHeaders = form.getHeaders();
//     axios.put("http://localhost:3000/quiz/" + quizId + "/picture", form, {
//         headers: {
//             ...formHeaders,
//             authorization: "Bearer " + user.token,
//         },
//     })
//         .then(function (response: any) {
//             console.log("Quiz pictures uploaded");
//         })
//         .catch(function (error: any) {
//             console.log("catch");
//             console.log(error);
//         });
// }
// async function uploadQuestionPicture(
//     user: any,
//     quizId: number,
//     imgUrl: string,
//     questionId: string
// ) {
//     const responseWiki = await axios({
//         url: imgUrl,
//         method: "GET",
//         responseType: "stream",
//     });
//     const form = new formData();
//     form.append("picture", responseWiki.data);

//     const formHeaders = form.getHeaders();
//     axios.put(
//         "http://localhost:3000/quiz/" +
//             quizId +
//             "/question/" +
//             questionId +
//             "/picture",
//         form,
//         {
//             headers: {
//                 ...formHeaders,
//                 authorization: "Bearer " + user.token,
//             },
//         }
//     )
//         .then(function (response: any) {
//             console.log("Question pictures uploaded well");
//         })
//         .catch(function (error: any) {
//             console.log("catch");
//             console.log(error);
//         });
// }

// async function uploadProfilePicture(userToken: any, imgUrl: string) {
//     const responseUnsplash = await axios({
//         url: imgUrl + "/download?force=true",
//         method: "GET",
//         responseType: "stream",
//     });
//     const form = new formData();
//     form.append("avatar", responseUnsplash.data);

//     const formHeaders = form.getHeaders();
//     axios.put("http://localhost:3000/user/profile/picture", form, {
//         headers: {
//             ...formHeaders,
//             authorization: "Bearer " + userToken,
//         },
//     })
//         .then(function (response: any) {
//             console.log("Profile pictures uploaded");
//         })
//         .catch(function (error: any) {
//             console.log("catch");
//             console.log(error);
//         });
// }
