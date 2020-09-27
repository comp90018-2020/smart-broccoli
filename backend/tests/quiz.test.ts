import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { createGroup, createQuiz, registerAndLogin } from "./helpers";
import { readFileSync } from "fs";
import { exception } from "console";

describe("Authentication", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };

    // Quiz/question
    const QUESTION_TF = {
        text: "a question",
        type: "truefalse",
        tf: false,
    };
    const QUESTION_CHOICE = {
        text: "a question",
        type: "choice",
        options: [
            {
                text: "abc",
                correct: false,
            },
            {
                text: "def",
                correct: true,
            },
        ],
    };
    const QUIZ = {
        title: "Quiz title",
        description: "Quiz description",
        questions: [QUESTION_TF, QUESTION_CHOICE],
        type: "live",
    };

    it("Create quiz", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");

        const res = await agent
            .post("/quiz")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ ...QUIZ, groupId: group.id });
        expect(res.status).to.equal(201);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("title");
        expect(res.body).to.have.property("description");
        expect(res.body).to.have.property("type");
        expect(res.body.title).to.equal(QUIZ.title);
        expect(res.body.type).to.equal(QUIZ.type);
        expect(res.body).to.have.property("questions");
        expect(res.body.questions).to.have.lengthOf(2);
        expect(res.body.questions[0]).to.have.property("type");
        expect(res.body.questions[0]).to.have.property("text");
        expect(res.body.questions[0].type).to.equal(QUESTION_TF.type);
        expect(res.body.questions[0].type).to.equal(QUESTION_TF.type);
        expect(res.body.questions[1].text).to.equal(QUESTION_CHOICE.text);
        expect(res.body.questions[1].text).to.equal(QUESTION_CHOICE.text);
    });

    it("Update quiz", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);

        const res = await agent
            .patch(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send({
                title: "a",
                description: "b",
                questions: [
                    // Delete a question (not seen)
                    // Create a new question
                    QUESTION_TF,
                    // Update a question
                    {
                        ...quiz.questions[1],
                        text: "new question text",
                        options: [
                            ...quiz.questions[1].options,
                            {
                                text: "ghi",
                                correct: false,
                            },
                        ],
                    },
                ],
            });
        expect(res.status).to.equal(200);
        expect(res.body.title).to.equal("a");
        expect(res.body.description).to.equal("b");
        expect(res.body.questions).to.have.lengthOf(2);
        expect(res.body.questions[0].id).to.not.equal(quiz.questions[0].id);
        expect(res.body.questions[1].id).to.equal(quiz.questions[1].id);
        expect(res.body.questions[1].text).to.equal("new question text");
        expect(res.body.questions[1].options).to.have.lengthOf(3);
    });

    // it("Get quiz", async () => {
    //     const agent = supertest(app);
    //     const user = await registerAndLogin(USER);
    //     const quiz = await createQuiz(user.id, QUIZ);
    //     await addQuestion(quiz.id, QUESTION_CHOICE);

    //     const res = await agent
    //         .get(`/quiz/${quiz.id}`)
    //         .set("Authorization", `Bearer ${user.token}`);
    //     expect(res.status).to.equal(200);
    //     expect(res.body).to.have.property("id");
    //     expect(res.body).to.have.property("questions");
    //     expect(res.body.questions).to.have.lengthOf(1);
    //     expect(res.body.questions[0]).to.have.property("options");
    //     expect(res.body.questions[0].options).to.deep.equal(
    //         QUESTION_CHOICE.options
    //     );
    // });

    // it("Get all quiz", async () => {
    //     const agent = supertest(app);
    //     const user = await registerAndLogin(USER);
    //     const quiz = await createQuiz(user.id, QUIZ);
    //     await addQuestion(quiz.id, QUESTION_CHOICE);

    //     const res = await agent
    //         .get(`/quiz`)
    //         .set("Authorization", `Bearer ${user.token}`);
    //     expect(res.status).to.equal(200);
    //     expect(res.body).to.be.an("array");
    //     expect(res.body).to.have.lengthOf(1);
    // });

    it("Delete quiz", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);

        const res = await agent
            .delete(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(res.status).to.equal(204);
    });

    it("Quiz question picture", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);

        // Update twice
        await agent
            .put(`/quiz/${quiz.id}/question/${quiz.questions[1].id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);
        const pictureRes = await agent
            .put(`/quiz/${quiz.id}/question/${quiz.questions[1].id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);
        expect(pictureRes.status).to.equal(200);

        // Now update quiz
        const r = await agent
            .patch(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send({
                title: "a",
                description: "b",
                questions: [
                    // Delete a question (not seen)
                    // Update a question
                    {
                        ...quiz.questions[1],
                        text: "new question text",
                        options: [
                            ...quiz.questions[1].options,
                            {
                                text: "ghi",
                                correct: false,
                            },
                        ],
                    },
                    // Create a new question
                    QUESTION_TF,
                ],
            });

        // Now get question picture
        const res = await agent
            .get(`/quiz/${quiz.id}/question/${quiz.questions[1].id}/picture`)
            .set("Authorization", `Bearer ${user.token}`);
        console.log(res.body);
        expect(res.status).to.equal(200);
    });
});
