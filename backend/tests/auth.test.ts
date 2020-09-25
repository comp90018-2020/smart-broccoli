import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin } from "./helpers";

describe("Authentication", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };

    it("Register", async () => {
        const agent = supertest(app);
        const res = await agent.post("/auth/register").send(USER);
        expect(res.status).to.equal(201);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("email");
        expect(res.body).to.have.property("name");
        expect(res.body).to.have.property("role");
        expect(res.body.role).to.equal("user");
    });

    it("Register duplicate", async () => {
        const agent = supertest(app);
        await agent.post("/auth/register").send(USER);
        const res = await agent.post("/auth/register").send(USER);
        expect(res.status).to.equal(409);
        expect(res.body.errors).to.be.an("array");
    });

    it("Login", async () => {
        const agent = supertest(app);
        await agent.post("/auth/register").send(USER);
        const res = await agent
            .post("/auth/login")
            .send({ email: USER.email, password: USER.password });
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("token");
    });

    it("Login bad password", async () => {
        const agent = supertest(app);
        await agent.post("/auth/register").send(USER);
        const res = await agent
            .post("/auth/login")
            .send({ email: USER.email, password: "abcdefgh" });
        expect(res.status).to.equal(403);
    });

    it("Session without token", async () => {
        const agent = supertest(app);
        const res = await agent.get("/auth/session").send();
        expect(res.status).to.equal(401);
    });

    it("Session with incorrect token", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const res = await agent
            .get("/auth/session")
            .set("Authorization", `Bearer ${user.token}a`)
            .send();
        expect(res.status).to.equal(403);
    });

    it("Session with token", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const res = await agent
            .get("/auth/session")
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(res.status).to.equal(200);
    });

    it("Join and retrieve session", async () => {
        const agent = supertest(app);

        // Join
        const joinRes = await agent.post("/auth/join");
        expect(joinRes.body).to.have.property("token");
        const token = joinRes.body.token;

        // Check session
        const res = await agent
            .get("/auth/session")
            .set("Authorization", `Bearer ${token}`)
            .send();
        expect(res.status).to.equal(200);
    });

    it("Join and promote", async () => {
        const agent = supertest(app);

        // Join
        const joinRes = await agent.post("/auth/join");
        expect(joinRes.body).to.have.property("token");
        const token = joinRes.body.token;

        // Promote
        const res = await agent
            .post("/auth/promote")
            .set("Authorization", `Bearer ${token}`)
            .send(USER);
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("email");
        expect(res.body).to.have.property("name");
        expect(res.body).to.have.property("role");
        expect(res.body.role).to.equal("user");

        // Ensure that new password can be used
        const loginRes = await agent
            .post("/auth/login")
            .send({ email: USER.email, password: USER.password });
        expect(loginRes.status).to.equal(200);
    });

    it("Logout", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const res = await agent
            .post("/auth/logout")
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(res.status).to.equal(200);

        const session = await agent
            .get("/auth/session")
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(session.status).to.equal(403);
    });

    it("Attempt login as participant", async () => {
        const agent = supertest(app);

        const joinRes = await agent.post("/auth/join");
        expect(joinRes.body).to.have.property("token");
        const token = joinRes.body.token;

        const updateRes = await agent
            .patch("/user/profile")
            .set("Authorization", `Bearer ${token}`)
            .send({
                email: "a@b.com",
                password: "aaaaaaaa",
            });
        expect(updateRes.status).to.equal(200);
        expect(updateRes.body).to.not.have.property('password');

        const loginRes = await agent
            .post("/auth/login")
            .send({ email: "a@b.com", password: "aaaaaaaa" });
        expect(loginRes.status).to.equal(403);
    });
});
