import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import {
    createGroup,
    createQuiz,
    registerAndLogin,
    joinGroup,
} from "./helpers";
import { readFileSync } from "fs";

describe("Quiz", () => {
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

    it("Create quiz with no questions", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");

        const { questions, ...rest } = QUIZ;
        const res = await agent
            .post("/quiz")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ ...rest, groupId: group.id });
        expect(res.status).to.equal(201);

        const badRes = await agent
            .post("/quiz")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ ...rest, questions: "1", groupId: group.id });
        expect(badRes.status).to.equal(400);
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

    it("Get quiz", async () => {
        const agent = supertest(app);
        const userAdmin = await registerAndLogin(USER);
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const group = await createGroup(userAdmin.id, "foo");
        // Active self-paced
        const quiz = await createQuiz(userAdmin.id, group.id, {
            ...QUIZ,
            active: true,
        });

        // Admin
        const res = await agent
            .get(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${userAdmin.token}`);
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("questions");
        expect(res.body.questions).to.have.lengthOf(2);
        expect(res.body.questions[1]).to.have.property("options");
        expect(res.body.questions[1].options).to.deep.equal(
            QUESTION_CHOICE.options
        );

        // Non-participant, non-member
        const nonRes = await agent
            .get(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(nonRes.status).to.equal(403);

        // Member
        await joinGroup(userMember.id, { name: "foo" });

        // Member, quiz not active
        const memberRes = await agent
            .get(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(memberRes.status).to.equal(200);
        expect(memberRes.body).to.have.property("id");
        expect(memberRes.body).to.have.property("questions");
        expect(memberRes.body.questions).to.equal(null);
    });

    it("Get all quiz", async () => {
        const agent = supertest(app);
        const user1 = await registerAndLogin(USER);
        const user2 = await registerAndLogin({ ...USER, email: "b@b.foo" });

        // Group 1 owned by user 1 (self-paced)
        const group1 = await createGroup(user1.id, "foo");
        const quiz1 = await createQuiz(user1.id, group1.id, {
            ...QUIZ,
            type: "live",
        });

        // Group 2 owned by user 2 with user 1 (live)
        const group2 = await createGroup(user2.id, "bar");
        const quiz2 = await createQuiz(user2.id, group2.id, {
            ...QUIZ,
            active: true,
            type: "self paced",
        });
        await joinGroup(user1.id, { name: "bar" });

        // Take quiz
        const ownedQuiz = await agent
            .get("/quiz?role=member")
            .set("Authorization", `Bearer ${user1.token}`);
        expect(ownedQuiz.status).to.equal(200);
        expect(ownedQuiz.body).to.be.an("array");
        expect(ownedQuiz.body).to.have.lengthOf(1);
        expect(ownedQuiz.body[0]).to.have.property("id");
        expect(ownedQuiz.body[0].id).to.equal(quiz2.id);

        // Managed
        const managedQuiz = await agent
            .get("/quiz?role=owner")
            .set("Authorization", `Bearer ${user1.token}`);
        expect(managedQuiz.status).to.equal(200);
        expect(managedQuiz.body).to.be.an("array");
        expect(managedQuiz.body).to.have.lengthOf(1);
        expect(managedQuiz.body[0]).to.have.property("id");
        expect(managedQuiz.body[0].id).to.equal(quiz1.id);

        // All
        const allQuiz = await agent
            .get("/quiz")
            .set("Authorization", `Bearer ${user1.token}`);
        expect(allQuiz.status).to.equal(200);
        expect(allQuiz.body).to.be.an("array");
        expect(allQuiz.body).to.have.lengthOf(2);
    });

    it("Get quiz of group", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);

        const res = await agent
            .get(`/group/${group.id}/quiz`)
            .set("Authorization", `Bearer ${user.token}`);
        expect(res.body).to.be.an("array");
        expect(res.body).to.have.lengthOf(1);
        expect(res.body[0]).to.have.property("id");
        expect(res.body[0].id).to.equal(quiz.id);
    });

    it("Quiz picture", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);

        // Update twice
        await agent
            .put(`/quiz/${quiz.id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);
        const pictureRes = await agent
            .put(`/quiz/${quiz.id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);
        expect(pictureRes.status).to.equal(200);

        // Now get quiz picture
        const res = await agent
            .get(`/quiz/${quiz.id}/picture`)
            .set("Authorization", `Bearer ${user.token}`);
        expect(res.status).to.equal(200);
    });

    it("Quiz picture retrieval - member self-paced", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, {
            ...QUIZ,
            type: "self paced",
            active: true,
        });
        await joinGroup(userMember.id, { code: group.code });

        // Update
        await agent
            .put(`/quiz/${quiz.id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${userOwner.token}`);

        const res = await agent
            .get(`/quiz/${quiz.id}/picture`)
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(res.status).to.equal(200);
    });

    it("Delete quiz picture", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);

        await agent
            .put(`/quiz/${quiz.id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);

        const res = await agent
            .delete(`/quiz/${quiz.id}/picture`)
            .set("Authorization", `Bearer ${user.token}`);
        expect(res.status).to.equal(204);

        const check = await agent
            .get(`/quiz/${quiz.id}/picture`)
            .set("Authorization", `Bearer ${user.token}`);
        expect(check.status).to.equal(404);
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
        await agent
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
        expect(res.status).to.equal(200);
    });

    it("Delete question picture", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);

        await agent
            .put(`/quiz/${quiz.id}/question/${quiz.questions[1].id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);

        const res = await agent
            .delete(`/quiz/${quiz.id}/question/${quiz.questions[1].id}/picture`)
            .set("Authorization", `Bearer ${user.token}`);
        expect(res.status).to.equal(204);

        const check = await agent
            .get(`/quiz/${quiz.id}/question/${quiz.questions[1].id}/picture`)
            .set("Authorization", `Bearer ${user.token}`);
        expect(check.status).to.equal(404);
    });

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

    it("Quiz picture retrieval - Inactive", async () => {
        const agent = supertest(app);

        // Login as registered
        const userOwner = await registerAndLogin(USER);

        // Create group/quiz
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, {
            ...QUIZ,
            type: "self paced",
            active: false,
        });
        // Set quiz picture
        await agent
            .put(`/quiz/${quiz.id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${userOwner.token}`);

        // Login as member
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        // Join group
        await joinGroup(userMember.id, { code: group.code });

        // Get all quiz and picture
        const resAll = await agent.get("/quiz")
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(resAll.status).to.equal(200);
        expect(resAll.body).to.have.lengthOf(0);
        const res = await agent
            .get(`/quiz/${quiz.id}/picture`)
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(res.status).to.equal(403);
    });

    it("Quiz picture retrieval - Active", async () => {
        const agent = supertest(app);

        // Login as registered
        const userOwner = await registerAndLogin(USER);

        // Create group/quiz
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, {
            ...QUIZ,
            type: "self paced",
            active: true,
        });
        // Set quiz picture
        await agent
            .put(`/quiz/${quiz.id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${userOwner.token}`);

        // Login as member
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        // Join group
        await joinGroup(userMember.id, { code: group.code });

        // Get all quiz and picture
        const resAll = await agent.get("/quiz")
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(resAll.status).to.equal(200);
        expect(resAll.body).to.have.lengthOf(1);
        const res = await agent
            .get(`/quiz/${quiz.id}/picture`)
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(res.status).to.equal(200);
    });
});
