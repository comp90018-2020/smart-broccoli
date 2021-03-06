import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import {
    createGroup,
    createQuiz,
    registerAndLogin,
    createSession,
    joinGroup,
} from "./helpers";
import { Token, UserState } from "../models";

describe("Notification", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };

    it("Set token", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        const res = await agent
            .post("/auth/firebase")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ token: "aaabbb" });
        expect(res.status).to.equal(200);
    });

    it("Set token replace", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        const first = await agent
            .post("/auth/firebase")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ token: "aaabbb" });
        expect(first.status).to.equal(200);

        const second = await agent
            .post("/auth/firebase")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ token: "aaabbb" });
        expect(second.status).to.equal(200);

        const res = await agent
            .post("/auth/firebase")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ oldToken: "aaabbb", token: "aaaaaa" });
        expect(res.status).to.equal(200);

        const tokens = await Token.findAll({ where: { scope: "firebase" } });
        expect(tokens.length).to.equal(1);
    });

    it("Update user notification state", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        await agent
            .put("/user/state")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ free: true, calendarFree: true });
        const res = await agent
            .put("/user/state")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ free: false, calendarFree: false });
        expect(res.status).to.equal(200);

        const states = await UserState.findAll();
        expect(states.length).to.equal(1);
        expect(states[0].free).to.equal(false);
        expect(states[0].calendarFree).to.equal(false);
    });

    it("Update/get user notification settings", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        const values = {
            onTheMove: false,
            onCommute: false,
            calendarLive: false,
            calendarSelfPaced: false,
            days: [true, true, false, false, true, false, true],
            timezone: "Australia/Melbourne",
            workSSID: "ABC",
            workLocation: "heh",
            workRadius: 5,
            workSmart: false,
            notificationWindow: 10,
            maxNotificationsPerDay: 100,
        };

        const res = await agent
            .put("/user/notification")
            .set("Authorization", `Bearer ${user.token}`)
            .send(values);
        expect(res.status).to.equal(200);

        expect(res.body).to.have.property("onTheMove");
        expect(res.body).to.have.property("onCommute");
        expect(res.body).to.have.property("calendarLive");
        expect(res.body).to.have.property("calendarSelfPaced");
        expect(res.body).to.have.property("days");
        expect(res.body).to.have.property("timezone");
        expect(res.body).to.have.property("workSSID");
        expect(res.body).to.have.property("workLocation");
        expect(res.body).to.have.property("workRadius");
        expect(res.body).to.have.property("workSmart");
        expect(res.body).to.have.property("notificationWindow");
        expect(res.body).to.have.property("maxNotificationsPerDay");

        expect(res.body.onTheMove).to.equal(values.onTheMove);
        expect(res.body.onCommute).to.equal(values.onCommute);
        expect(res.body.calendarLive).to.equal(values.calendarLive);
        expect(res.body.calendarSelfPaced).to.equal(values.calendarSelfPaced);
        expect(res.body.days).to.deep.equal(values.days);
        expect(res.body.timezone).to.equal(values.timezone);
        expect(res.body.workSSID).to.equal(values.workSSID);
        expect(res.body.workLocation).to.equal(values.workLocation);
        expect(res.body.workRadius).to.equal(values.workRadius);
        expect(res.body.workSmart).to.equal(values.workSmart);
        expect(res.body.notificationWindow).to.equal(values.notificationWindow);
        expect(res.body.maxNotificationsPerDay).to.equal(
            values.maxNotificationsPerDay
        );
    });

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

    it("'Trigger' notification", async () => {
        const agent = supertest(app);
        const owner1 = await registerAndLogin({ ...USER, email: "b@b.com" });
        const owner2 = await registerAndLogin({ ...USER, email: "c@c.com" });
        const user = await registerAndLogin(USER);

        // Set token
        const token = await agent
            .post("/auth/firebase")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ token: "aaabbb" });
        expect(token.status).to.equal(200);

        const values = {
            onTheMove: false,
            onCommute: false,
            calendarLive: false,
            calendarSelfPaced: false,
            days: [true, true, false, false, true, false, true],
            timezone: "Australia/Melbourne",
            ssid: "ABC",
            location: "heh",
            radius: 5,
            notificationWindow: 5,
            maxNotificationsPerDay: 100,
        };
        const res = await agent
            .put("/user/notification")
            .set("Authorization", `Bearer ${user.token}`)
            .send(values);
        expect(res.status).to.equal(200);
        expect(res.body.notificationWindow).to.equal(values.notificationWindow);
        expect(res.body.maxNotificationsPerDay).to.equal(
            values.maxNotificationsPerDay
        );

        // Create group/quiz
        const group = await createGroup(owner1.id, "foo");
        const group2 = await createGroup(owner2.id, "bar");
        const quiz = await createQuiz(owner1.id, group.id, QUIZ);
        const quiz2 = await createQuiz(owner2.id, group2.id, QUIZ);

        // Join group
        await joinGroup(user.id, { code: group.code });
        await joinGroup(user.id, { code: group2.code });

        // Start live quiz, user 'gets' notification
        await createSession(owner1.id, {
            quizId: quiz.id,
            isGroup: false,
        });
        // Start second live quiz, user should got 'get' notification
        await createSession(owner2.id, {
            quizId: quiz2.id,
            isGroup: false,
        });
    });
});
