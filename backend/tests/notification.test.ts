import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin } from "./helpers";
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
            ssid: "ABC",
            location: "heh",
            radius: 5,
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
        expect(res.body).to.have.property("ssid");
        expect(res.body).to.have.property("location");
        expect(res.body).to.have.property("radius");
        expect(res.body).to.have.property("notificationWindow");
        expect(res.body).to.have.property("maxNotificationsPerDay");

        expect(res.body.onTheMove).to.equal(false);
        expect(res.body.onCommute).to.equal(false);
        expect(res.body.calendarLive).to.equal(false);
        expect(res.body.calendarSelfPaced).to.equal(false);
        expect(res.body.days).to.deep.equal([
            true,
            true,
            false,
            false,
            true,
            false,
            true,
        ]);
        expect(res.body.timezone).to.equal("Australia/Melbourne");
        expect(res.body.ssid).to.equal("ABC");
        expect(res.body.location).to.equal(null);
        expect(res.body.radius).to.equal(5);
        expect(res.body.notificationWindow).to.equal(10);
        expect(res.body.maxNotificationsPerDay).to.equal(100);
    });
});
