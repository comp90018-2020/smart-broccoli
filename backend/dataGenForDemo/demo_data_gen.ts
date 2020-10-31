import token from "token";

const authCntr = require('../controllers/auth');
const groupCntr = require('../controllers/group');
const quizCntr = require('../controllers/quiz');
import Question, { OptionAttributes } from "../models/question";
import User from "user";
var fs = require('fs');
const Path = require('path')
const Axios = require('axios')
import rebuild from "../tests/rebuild";
var FormData = require('form-data');


/**
 *  The script generates 10 users, 10 groups, 2 quizzes that are filled, and 8 quizzes that are empty. 2 filled quizzes are within the "Fine Arts" group that is joined by all users,
 *  each quiz has 4 questions with 4 answers, no picture upload yet.
 *  The script starts with completely erasing the database.

 * To launch call {{ base_url }}/demo/demoDataGen via postman


 * */

let names = ["Haydon Holding",
    "Blade Taylor",
    "Kia Mckenna",
    "Buster Guevara",
    "Aiden Bean",
    "Daisie Berger",
    "Alfred Paul",
    "Ayah Craig",
    "Anwen Rojas",
    "Glenda Wormald"];

let password = "12345678"
let email = "@gmail.com"

export const accountDataGen = async () =>{

    await rebuild()
    let users:any =  [];
    for (let i = 0; i < names.length; i++) {
        let user = await authCntr.register({  email: (names[i].split(" ")[0]).toLowerCase() + email, password: password,  name: names[i] })
        const params = JSON.stringify({
            email: user.email,
            password: "12345678",
        });

        Axios.post("http://localhost:3000/auth/login", params,{

            "headers": {
                "content-type": "application/json",
            },
        })
            .then(function(response: any) {
                user.token = response.data.token
                users.push(user)
            })

            .catch(function(error: any) {
                console.log("catch")
                console.log(error);
            });

    };

    await groupDataGen(users)
}


let groupNames =
    [["Fine Arts", "Architecture", "Art History", "Design", "Film Studies",  "Graphic Design"],
        ["Management", "Accounting", "Entrepreneurship", "Finance","Marketing", "Negotiations"]]

async function groupDataGen(users: any[]) {
//For creation of quizes only groups in first array are used, these are groups for arts quizes
    var groupsId:number[][]=[ [],[] ]
    let groupNamesForJoinFunction: string[] = []
    for (let i = 0; i < 2; i++) {
        for (let j = 0; j<groupNames[i].length; j++){
            let group = await groupCntr.createGroup(users[i].id, groupNames[i][j], false);
            groupsId[i].push(group.id)
            groupNamesForJoinFunction.push(group.name)
        }
    }
    await  joinGroups(users, groupNamesForJoinFunction);
   await questionDataGen(users, groupsId);
}


async function joinGroups(users: any[], groupNamesForJoinFunction: string[]){
    for (let j = 0; j<2;j++){
        for (let i = 1; i<users.length; i++){
            await groupCntr.joinGroup(users[i].id, {name: groupNamesForJoinFunction[j]});
        }
    }
}

let questionsPainting =
    [
        {question: "The Birth of Venus is considered to be one of the top 10 paintings of all time. Who made it?",
            imgUrl:"",
            answers: [{correct: true, text: "Sandro Botticelli"},{correct: false, text: "Claude Monet"},  {correct: false, text: "Rembrandt van Rijn"}, {correct: false, text: "Edvard Munch"}]},
        {question: "Which famous painting is also referred to as The Dutch Monalisa",
            imgUrl:"",
            answers:[{correct: true, text: "Girl with a Pearl Earring"}, {correct: false, text: "Guernica"}, {correct: false, text: "Night Watch"},  {correct: false, text: "Dutch Mona Lisa"}] },
        {question: "Guernica is one of Pablo Piccaso's famous paintings. In which year did he complete it?",
            imgUrl:"",
            answers: [ {correct: true, text: "1937"}, {correct: false, text: "1934"}, {correct: false, text: "1935"}, {correct: false, text: "1936"}]} ,
        {question: "Where would you find the painting The Last Supper",
            imgUrl:"",
            answers: [{correct: true, text: "Milan"}, {correct: false, text: "Venice"}, {correct: false, text: "Rome"}, {correct: false, text: "Naples"}]}
    ]
let questionsSculpture =
    [
        {question: "What can you infer about prehistoric sculpture?",
            imgUrl:"",
            answers: [{correct: true, text: "It usually depicted animals and humans"},{correct: false, text: "It usually depicted landscapes"},{correct: false, text: "It usually depicted imaginary, mythical creatures"},{correct: false, text: "It usually depicted abstract forms"}]},
        {question: "Which term best describes Michelangelo's sculpture of David?",
            imgUrl:"",
            answers: [{correct: true, text: "Realistic"}, {correct: false, text: "Two-dimensional"}, {correct: false, text: "Exaggerated"}, {correct: false, text: "Abstract"}, ]},
        {question: "Tim's walking around a sculpture to get a good look at its back. What style of sculpture must it be?",
            imgUrl:"",
            answers: [{correct: true, text: "In the round"}, {correct: false, text: "Prehistoric"}, {correct: false, text: "Relief"}, {correct: false, text: "Monumental"}, ]},
        {question: "An armature is most similar to:",
            imgUrl:"",
            answers: [{correct: true, text: "The pillars and beams that hold up a building"}, {correct: false, text: "An architect's blueprint for a building"},
                {correct: false, text: "The plaster that covers the walls of a building"}, {correct: false, text: "The art that decorates a building"}]
        },
    ]

class TempQuestion {
    text: string;
    type: string;
    tf: boolean
    options: OptionAttributes[];
}

let questionsForQuiz =  [questionsPainting, questionsSculpture]

//Questions generated only by the first user
async function questionDataGen(users: any[], groupId: number [][]) {
    let questions:any[][]=[ [],[] ]
    for (let i = 0; i<quizArray.length;i++){
        for (let j = 0; j < questionsForQuiz[i].length; j++){
            let question = new TempQuestion();
            let item = questionsForQuiz[i][j];
            question.text = item.question;
            question.type = "choice";
            question.tf = false;
            question.options = [];
            for(let e = 0; e < questionsForQuiz[i][j].answers.length; e++){
                let answer = questionsForQuiz[i][j].answers[e];
                question.options.push(answer)
            }
            questions[i].push(question)
        }
    }
    await quizDataGen(users, groupId, questions)

}


let quizNamesFineArts = [
    {name:"Painting", imgUrl:"https://unsplash.com/photos/1rBg5YSi00c"},
    {name:"Sculpture",imgUrl:"https://unsplash.com/photos/AUgTvvQxDhg" },
    {name:"Mosaics",imgUrl:"https://unsplash.com/photos/jy4oF77LQmM" },
    {name:"Music",imgUrl:"https://unsplash.com/photos/laHwVPkMTzY" },
    {name:"Poetry",imgUrl:"https://unsplash.com/photos/FDzRG30DeVM" }]
let quizNameManagement = [
    {name:"Human Resource Fundamentals",imgUrl:"https://unsplash.com/photos/DsCfl94sWz4" },
    {name:"Managerial Economics",imgUrl:"https://unsplash.com/photos/OtfnlTw0lH4" },
    {name:"Managing People",imgUrl:"https://unsplash.com/photos/fznQW-kn5VU" },
    {name:"Managerial Psychology",imgUrl:"https://unsplash.com/photos/cAQZuqdvba8" },
    {name:"Business Analysis & Decision Making",imgUrl:"https://unsplash.com/photos/J3AV8F-B42M" }]

let quizArray = [quizNamesFineArts, quizNameManagement]

let quizType = ["live", "self paced"]

async function quizDataGen(users: any[], groupId: number[][], questions: any[][]) {


    for (let i = 0; i< (quizArray[0].length);i++ ){
        let pickedQuizType
        if (i % 2 == 0) {
            pickedQuizType = quizType[1]
        } else {
            pickedQuizType = quizType [0]
        }
        if(i<2) {
            let quiz = await quizCntr.createQuiz(users[0].id, {
                groupId: groupId[0][0],
                type: pickedQuizType,
                title: quizArray[0][i].name,
                timeLimit: 10,
                questions: questions[i]
            })

            console.log(quiz.questions.length)
            //uploadQuizPicture(users[0], quiz.id,quizArray[0][i].imgUrl)

            for (let j = 0; j< quiz.questions.length; j++){
                console.log("203")
                uploadQuestionPicture(users[0], quiz.id, questionsForQuiz[i][j].imgUrl, quiz.questions[j].id)
            }
        }
        else if (i>=2 && i<quizArray[0].length){
            let quiz = await quizCntr.createQuiz(users[0].id, {
                groupId: groupId[0][0],
                type: pickedQuizType,
                title: quizArray[0][i].name,
                timeLimit: 10,
                questions: []
            })
            //uploadQuizPicture(users[0], quiz.id,quizArray[0][i].imgUrl)
        }
    }


    for (let i = 0; i< quizArray[1].length;i++ ){
        let pickedQuizType
        if (i % 2 == 0) {
            pickedQuizType = quizType[1]
        } else {
            pickedQuizType = quizType [0]
        }
        let quiz = await quizCntr.createQuiz(users[1].id, {
            groupId: groupId[1][0],
            type: pickedQuizType,
            title: quizArray[1][i].name,
            timeLimit: 10,
            questions: []
        })
        //uploadQuizPicture(users[1], quiz.id,quizArray[0][i].imgUrl)
    }
}

async function  uploadQuizPicture(user: any, quizId: number, imgUrl: string) {

    imgUrl = imgUrl + "/download?force=true"
    console.log(imgUrl)
    const responseUnsplash = await Axios({
        url: imgUrl,
        method: 'GET',
        responseType: 'stream'
    })

    const form = new FormData();
    form.append('picture', responseUnsplash.data)

    const formHeaders = form.getHeaders();
    Axios.put("http://localhost:3000/quiz/" + quizId + "/picture", form,{
        "headers": {
            ...formHeaders,
            "authorization": "Bearer " + user.token
        },
    })
        .then(function(response: any) {
            console.log("all good")
        })
        .catch(function(error: any) {
            console.log("catch")
            console.log(error)
        });
}
async function  uploadQuestionPicture(user: any, quizId: number, imgUrl: string, questionId: string){
    console.log("upload picture process")

    imgUrl = imgUrl + "/download?force=true"
    const responseUnsplash = await Axios({
        url: imgUrl,
        method: 'GET',
        responseType: 'stream'
    })

    const form = new FormData();
    form.append('picture', responseUnsplash.data)

    const formHeaders = form.getHeaders();
    Axios.put("http://localhost:3000/quiz/" + quizId + "/question/" +questionId + "/picture", form,{
        "headers": {
            ...formHeaders,
            "authorization": "Bearer " + user.token
        },
    })
        .then(function(response: any) {
            console.log("Quiz pictures uploaded well")
        })
        .catch(function(error: any) {
            console.log("catch")
            console.log(error)
        });
}


