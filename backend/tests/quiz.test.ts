import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin, createQuiz } from "./helpers";
import { addQuestion } from "../controllers/quiz";

describe("Authentication", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };
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

    it("Create quiz", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        const res = await agent
            .post("/quiz")
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(res.status).to.equal(201);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("title");
        expect(res.body).to.have.property("description");
    });

    it("Update quiz attributes", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const quiz = await createQuiz(user.id);

        const res = await agent
            .patch(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send({ title: "a", description: "b" });
        expect(res.status).to.equal(200);
        expect(res.body.title).to.equal("a");
        expect(res.body.description).to.equal("b");
    });

    it("Add truefalse question", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const quiz = await createQuiz(user.id);

        const res = await agent
            .post(`/quiz/${quiz.id}/question`)
            .set("Authorization", `Bearer ${user.token}`)
            .send(QUESTION_TF);
        expect(res.status).to.equal(201);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("type");
        expect(res.body).to.have.property("tf");
        expect(res.body.type).to.equal(QUESTION_TF.type);
        expect(res.body.tf).to.equal(QUESTION_TF.tf);
        expect(res.body.text).to.equal(QUESTION_TF.text);
    });

    it("Add choice question", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const quiz = await createQuiz(user.id);

        const res = await agent
            .post(`/quiz/${quiz.id}/question`)
            .set("Authorization", `Bearer ${user.token}`)
            .send(QUESTION_CHOICE);
        expect(res.status).to.equal(201);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("type");
        expect(res.body.type).to.equal(QUESTION_CHOICE.type);
        expect(res.body).to.have.property("options");
        expect(res.body.options).to.deep.equal(QUESTION_CHOICE.options);
    });

    it("Update choice question", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const quiz = await createQuiz(user.id);
        const question = await addQuestion(user.id, quiz.id, QUESTION_CHOICE);

        // Slightly modified
        const modified = {
            ...QUESTION_CHOICE,
            options: [
                QUESTION_CHOICE.options[0],
                { text: "ghi", correct: true },
            ],
        };
        const res = await agent
            .put(`/quiz/${quiz.id}/question/${question.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send(modified);
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("options");
        expect(res.body.options).to.deep.equal(modified.options);
    });

    it("Delete question", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const quiz = await createQuiz(user.id);
        const question = await addQuestion(user.id, quiz.id, QUESTION_CHOICE);

        const res = await agent
            .delete(`/quiz/${quiz.id}/question/${question.id}`)
            .set("Authorization", `Bearer ${user.token}`);
        expect(res.status).to.equal(200);
    });

    it("Delete quiz", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const quiz = await createQuiz(user.id);
        await addQuestion(user.id, quiz.id, QUESTION_TF);

        const res = await agent
            .delete(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(res.status).to.equal(200);
    });
});
