import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin } from "./helpers";
import { readFileSync } from "fs";

describe("User", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };

    it("Get profile", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const res = await agent
            .get("/user/profile")
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("email");
        expect(res.body).to.have.property("name");
        expect(res.body).to.have.property("role");
    });

    it("Update profile", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        const UPDATE = { email: "b@b.com", name: "b" };
        const res = await agent
            .patch("/user/profile")
            .set("Authorization", `Bearer ${user.token}`)
            .send(UPDATE);
        expect(res.body).to.have.property("id");
        expect(res.body.email).to.equal(UPDATE.email);
        expect(res.body.name).to.equal(UPDATE.name);
    });

    it("Update profile common email", async () => {
        const agent = supertest(app);
        await registerAndLogin({ ...USER, email: "b@b.com" });
        const user = await registerAndLogin(USER);

        const UPDATE = { email: "b@b.com", name: "b" };
        const res = await agent
            .patch("/user/profile")
            .set("Authorization", `Bearer ${user.token}`)
            .send(UPDATE);
        expect(res.status).to.equal(409);
    });

    it("Update profile password", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        const UPDATE = { password: "abcdefgh" };
        await agent
            .patch("/user/profile")
            .set("Authorization", `Bearer ${user.token}`)
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
        const user = await registerAndLogin(USER);

        const res = await agent
            .put("/user/profile/picture")
            .attach("avatar", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);
        expect(res.status).to.equal(200);
    });

    it("Get profile picture", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        await agent
            .put("/user/profile/picture")
            .attach("avatar", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);
        await agent
            .put("/user/profile/picture")
            .attach("avatar", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);

        const res = await agent
            .get("/user/profile/picture")
            .set("Authorization", `Bearer ${user.token}`);
        expect(res.status).to.equal(200);
    });

    it("Delete profile picture", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        await agent
            .put("/user/profile/picture")
            .attach("avatar", readFileSync(`${__dirname}/assets/yc.png`), {
                filename: "yc.png",
            })
            .set("Authorization", `Bearer ${user.token}`);

        const res = await agent
            .delete("/user/profile/picture")
            .set("Authorization", `Bearer ${user.token}`);
        expect(res.status).to.equal(204);

        const check = await agent
            .get("/user/profile/picture")
            .set("Authorization", `Bearer ${user.token}`);
        expect(check.status).to.equal(404);
    });
});
