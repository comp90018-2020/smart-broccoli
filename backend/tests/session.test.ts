import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import {
    createGroup,
    createQuiz,
    registerAndLogin,
    createSession,
    joinSession,
    joinGroup,
} from "./helpers";
import { jwtVerify } from "../helpers/jwt";
import { activateSession, leaveSession } from "../controllers/session";
import { readFileSync } from "fs";

describe("Session", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a name",
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

    it("Create session", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);

        const res = await agent
            .post("/session")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ quizId: quiz.id, isGroup: false });
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("session");
        expect(res.body).to.have.property("token");
        expect(res.body.session).to.have.property("id");
        expect(res.body.session).to.have.property("quizId");
        expect(res.body.session).to.have.property("code");
        expect(res.body.session).to.have.property("state");
        expect(res.body.session.code).to.have.lengthOf(6);
        expect(res.body.session.state).to.equal("waiting");

        const token: any = await jwtVerify(
            res.body.token,
            process.env.TOKEN_SECRET
        );
        expect(token).to.have.property("scope");
        expect(token).to.have.property("sessionId");
        expect(token).to.have.property("userId");
        expect(token).to.have.property("role");
        expect(token.scope).to.equal("game");
        expect(token.sessionId).to.equal(res.body.session.id);
        expect(token.userId).to.equal(user.id);
        expect(token.role).to.equal("host");
    });

    it("Create session twice", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, QUIZ);

        // Owner starts live session
        await createSession(userOwner.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        // Start again
        const res = await agent
            .post("/session")
            .set("Authorization", `Bearer ${userOwner.token}`)
            .send({ quizId: quiz.id, isGroup: false });
        expect(res.status).to.equal(400);
    });

    it("Get session", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "foo");
        const quiz = await createQuiz(user.id, group.id, QUIZ);
        await createSession(user.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        const res = await agent
            .get("/session")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ quizId: quiz.id, isGroup: false });
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("session");
        expect(res.body).to.have.property("token");
        expect(res.body.session).to.have.property("id");
        expect(res.body.session).to.have.property("quizId");
        expect(res.body.session).to.have.property("code");
        expect(res.body.session).to.have.property("state");
        expect(res.body.session).to.have.property("type");
        expect(res.body.session.code).to.have.lengthOf(6);
        expect(res.body.session.state).to.equal("waiting");

        const token: any = await jwtVerify(
            res.body.token,
            process.env.TOKEN_SECRET
        );
        expect(token).to.have.property("scope");
        expect(token).to.have.property("sessionId");
        expect(token).to.have.property("userId");
        expect(token).to.have.property("role");
        expect(token.scope).to.equal("game");
        expect(token.sessionId).to.equal(res.body.session.id);
        expect(token.userId).to.equal(user.id);
        expect(token.role).to.equal("host");
    });

    it("Join session", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, QUIZ);
        const session = await createSession(userOwner.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        const res = await agent
            .post("/session/join")
            .set("Authorization", `Bearer ${userMember.token}`)
            .send({ code: session.session.code });
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("session");
        expect(res.body).to.have.property("token");
        expect(res.body.session).to.have.property("id");
        expect(res.body.session).to.have.property("quizId");
        expect(res.body.session).to.have.property("code");
        expect(res.body.session).to.have.property("state");
        expect(res.body.session).to.have.property("type");
        expect(res.body.session.code).to.have.lengthOf(6);
        expect(res.body.session.state).to.equal("waiting");

        const token: any = await jwtVerify(
            res.body.token,
            process.env.TOKEN_SECRET
        );
        expect(token).to.have.property("scope");
        expect(token).to.have.property("sessionId");
        expect(token).to.have.property("userId");
        expect(token).to.have.property("role");
        expect(token.scope).to.equal("game");
        expect(token.sessionId).to.equal(res.body.session.id);
        expect(token.userId).to.equal(userMember.id);
        expect(token.role).to.equal("participant");

        // Get to check
        const getRes = await agent
            .get("/session")
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(getRes.status).to.equal(200);
    });

    it("Get quiz after session", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, QUIZ);
        const session = await createSession(userOwner.id, {
            quizId: quiz.id,
            isGroup: false,
        });
        await joinSession(userMember.id, session.session.code);
        await joinGroup(userMember.id, { code: group.code });

        const quizAllRes = await agent
            .get("/quiz")
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(quizAllRes.status).to.equal(200);
        expect(quizAllRes.body).to.have.lengthOf(1);
        expect(quizAllRes.body[0]).to.have.property("Sessions");
        expect(quizAllRes.body[0].Sessions).to.have.lengthOf(1);

        const quizRes = await agent
            .get(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(quizRes.status).to.equal(200);
        expect(quizRes.body).to.have.property("questions");
        expect(quizRes.body.questions).to.have.lengthOf(2);
        expect(quizRes.body).to.have.property("Sessions");
        expect(quizRes.body.questions[1]).to.have.property("numCorrect");
        expect(quizRes.body.questions[1].numCorrect).to.equal(1);
        expect(quizRes.body.Sessions).to.have.lengthOf(1);

        const groupQuizRes = await agent
            .get(`/group/${group.id}/quiz`)
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(groupQuizRes.body).to.have.lengthOf(1);
        expect(groupQuizRes.body[0]).to.have.property("Sessions");
        expect(groupQuizRes.body[0].Sessions).to.have.lengthOf(1);
    });

    it("Get quiz - session multiple users", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember1 = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const userMember2 = await registerAndLogin({
            ...USER,
            email: "c@c.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, {
            ...QUIZ,
            active: true,
            type: "self paced",
        });
        await joinGroup(userMember1.id, { code: group.code });
        await joinGroup(userMember2.id, { code: group.code });

        await createSession(userMember1.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        // GET /quiz
        const quizAllMember1 = await agent
            .get("/quiz")
            .set("Authorization", `Bearer ${userMember1.token}`);
        expect(quizAllMember1.body).to.have.lengthOf(1);
        expect(quizAllMember1.body[0].Sessions).to.have.lengthOf(1);
        expect(quizAllMember1.body[0].role).to.equal("member");

        const quizAllMember2 = await agent
            .get("/quiz")
            .set("Authorization", `Bearer ${userMember2.token}`);
        expect(quizAllMember2.body).to.have.lengthOf(1);
        expect(quizAllMember2.body[0].Sessions).to.have.lengthOf(0);
        expect(quizAllMember2.body[0].role).to.equal("member");

        const quizAllOwner = await agent
            .get("/quiz")
            .set("Authorization", `Bearer ${userOwner.token}`);
        expect(quizAllOwner.body).to.have.lengthOf(1);
        expect(quizAllOwner.body[0].Sessions).to.have.lengthOf(0);
        expect(quizAllOwner.body[0].role).to.equal("owner");

        // GET /quiz/:id
        const quizMember1 = await agent
            .get(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${userMember1.token}`);
        expect(quizMember1.body).to.have.property("Sessions");
        expect(quizMember1.body.Sessions).to.have.lengthOf(1);

        const quizMember2 = await agent
            .get(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${userMember2.token}`);
        expect(quizMember2.body).to.have.property("Sessions");
        expect(quizMember2.body.Sessions).to.have.lengthOf(0);

        const quizOwner = await agent
            .get(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${userOwner.token}`);
        expect(quizOwner.body).to.have.property("Sessions");
        expect(quizOwner.body.Sessions).to.have.lengthOf(0);

        // GET /group/quiz
        const groupMember1 = await agent
            .get(`/group/${group.id}/quiz`)
            .set("Authorization", `Bearer ${userMember1.token}`);
        expect(groupMember1.body).to.have.lengthOf(1);
        expect(groupMember1.body[0].Sessions).to.have.lengthOf(1);

        const groupMember2 = await agent
            .get(`/group/${group.id}/quiz`)
            .set("Authorization", `Bearer ${userMember2.token}`);
        expect(groupMember2.body).to.have.lengthOf(1);
        expect(groupMember2.body[0].Sessions).to.have.lengthOf(0);

        const groupOwner = await agent
            .get(`/group/${group.id}/quiz`)
            .set("Authorization", `Bearer ${userOwner.token}`);
        expect(groupOwner.body).to.have.lengthOf(1);
        expect(groupOwner.body[0].Sessions).to.have.lengthOf(0);
    });

    it("Join other users' self-paced session", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember1 = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const userMember2 = await registerAndLogin({
            ...USER,
            email: "c@c.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, {
            ...QUIZ,
            active: true,
            type: "self paced",
        });

        // Both members join group
        await joinGroup(userMember1.id, { code: group.code });
        await joinGroup(userMember2.id, { code: group.code });

        // User 1 start alone session
        const session = await createSession(userMember1.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        // User 2 join session
        const res = await agent
            .post("/session/join")
            .set("Authorization", `Bearer ${userMember2.token}`)
            .send({ code: session.session.code });
        expect(res.status).to.equal(400);
    });

    it("Rejoin session", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, QUIZ);

        // Owner starts live session
        const session = await createSession(userOwner.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        // User join session
        await joinSession(userMember.id, session.session.code);

        // User leave sessoin
        await leaveSession(session.session.id, userMember.id);

        // User join session
        const res = await agent
            .post("/session/join")
            .set("Authorization", `Bearer ${userMember.token}`)
            .send({ code: session.session.code });
        expect(res.status).to.equal(200);
    });

    it("Join session after activation", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember1 = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const userMember2 = await registerAndLogin({
            ...USER,
            email: "c@c.com",
        });
        const userMember3 = await registerAndLogin({
            ...USER,
            email: "d@d.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, {
            ...QUIZ,
            type: "self paced",
            active: true,
        });
        await joinGroup(userMember1.id, { code: group.code });
        await joinGroup(userMember2.id, { code: group.code });
        await joinGroup(userMember3.id, { code: group.code });

        // User 1 start group session
        const session = await createSession(userMember1.id, {
            quizId: quiz.id,
            isGroup: true,
        });

        // User 2 join session
        await joinSession(userMember2.id, session.session.code);
        // User 2 leave session
        await leaveSession(session.session.id, userMember2.id);

        // Session activates
        await activateSession(session.session.id);

        // User join session
        const res = await agent
            .post("/session/join")
            .set("Authorization", `Bearer ${userMember3.token}`)
            .send({ code: session.session.code });
        expect(res.status).to.equal(400);
    });

    it("Join session twice", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, QUIZ);

        // Owner starts live session
        const session = await createSession(userOwner.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        // User join session
        await joinSession(userMember.id, session.session.code);

        // User join session
        const res = await agent
            .post("/session/join")
            .set("Authorization", `Bearer ${userMember.token}`)
            .send({ code: session.session.code });
        expect(res.status).to.equal(400);
    });

    it("Use token to get user info", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, QUIZ);

        // Owner starts live session
        const session = await createSession(userOwner.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        // User join session
        const sessionUser = await joinSession(
            userMember.id,
            session.session.code
        );
        expect(sessionUser).to.have.property("token");

        const res = await agent
            .get(`/user/${userOwner.id}/profile`)
            .set("Authorization", `Bearer ${sessionUser.token}`);
        expect(res.status).to.equal(200);
    });

    it("Get picture in session", async () => {
        const agent = supertest(app);
        const userOwner = await registerAndLogin(USER);
        const userMember = await registerAndLogin({
            ...USER,
            email: "b@b.com",
        });
        const group = await createGroup(userOwner.id, "foo");
        const quiz = await createQuiz(userOwner.id, group.id, QUIZ);
        const session = await createSession(userOwner.id, {
            quizId: quiz.id,
            isGroup: false,
        });

        const setQuizPictureRes = await agent
            .put(`/quiz/${quiz.id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${userOwner.token}`);
        expect(setQuizPictureRes.status).to.equal(200);
        const setQuestionPictureRes = await agent
            .put(`/quiz/${quiz.id}/question/${quiz.questions[0].id}/picture`)
            .attach("picture", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${userOwner.token}`);
        expect(setQuestionPictureRes.status).to.equal(200);

        const res = await agent
            .post("/session/join")
            .set("Authorization", `Bearer ${userMember.token}`)
            .send({ code: session.session.code });
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("token");

        const getQuizPictureRes = await agent
            .get(`/quiz/${quiz.id}/picture`)
            .set("Authorization", `Bearer ${res.body.token}`);
        expect(getQuizPictureRes.status).to.equal(200);

        const getQuestionPictureRes = await agent
            .get(`/quiz/${quiz.id}/question/${quiz.questions[0].id}/picture`)
            .set("Authorization", `Bearer ${res.body.token}`);
        expect(getQuestionPictureRes.status).to.equal(200);
    });
});
