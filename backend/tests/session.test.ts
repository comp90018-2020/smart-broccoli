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

describe("Session", () => {
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
            .get(`/quiz`)
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
        expect(quizRes.body.Sessions).to.have.lengthOf(1);

        const groupQuizRes = await agent
            .get(`/group/${group.id}/quiz`)
            .set("Authorization", `Bearer ${userMember.token}`);
        expect(groupQuizRes.body).to.have.lengthOf(1);
        expect(groupQuizRes.body[0]).to.have.property("Sessions");
        expect(groupQuizRes.body[0].Sessions).to.have.lengthOf(1);
    });
});
