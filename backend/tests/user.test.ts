import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin } from "./helpers";
import { readFileSync } from "fs";

describe("Authentication", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };

    it("Update profile", async () => {
        const agent = supertest(app);
        const token = await registerAndLogin(USER);

        const UPDATE = { email: "b@b.com", name: "b" };
        const res = await agent
            .patch("/user/profile")
            .set("Authorization", `Bearer ${token}`)
            .send(UPDATE);
        expect(res.body).to.have.property("id");
        expect(res.body.email).to.equal(UPDATE.email);
        expect(res.body.name).to.equal(UPDATE.name);
    });

    it("Update profile common email", async () => {
        const agent = supertest(app);
        await registerAndLogin({ ...USER, email: "b@b.com" });
        const token = await registerAndLogin(USER);

        const UPDATE = { email: "b@b.com", name: "b" };
        const res = await agent
            .patch("/user/profile")
            .set("Authorization", `Bearer ${token}`)
            .send(UPDATE);
        expect(res.status).to.equal(409);
    });

    it("Update profile password", async () => {
        const agent = supertest(app);
        const token = await registerAndLogin(USER);

        const UPDATE = { password: "abcdefgh" };
        await agent
            .patch("/user/profile")
            .set("Authorization", `Bearer ${token}`)
            .send(UPDATE);

        const loginSuccess = await agent
            .post("/auth/login")
            .send({ email: USER.email, password: "abcdefgh" });
        expect(loginSuccess.body).to.have.property("token");

        const loginFailure = await agent
            .post("/auth/login")
            .send({ email: USER.email, password: "aaaaaaaa" });
        expect(loginFailure.status).equal(403);
    });

    it("Upload profile picture", async () => {
        const agent = supertest(app);
        const token = await registerAndLogin(USER);

        const res = await agent
            .put("/user/profile/picture")
            .attach("avatar", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${token}`);
        expect(res.status).to.equal(200);
    });
});
