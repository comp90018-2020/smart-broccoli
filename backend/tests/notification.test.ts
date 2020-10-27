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

        const second= await agent
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
            .send({ free: true });
        const res = await agent
            .put("/user/state")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ free: false });
        expect(res.status).to.equal(200);

        const states = await UserState.findAll();
        // console.log(states);
        expect(states.length).to.equal(1);
        expect(states[0].free).to.equal(false);
    });
});
