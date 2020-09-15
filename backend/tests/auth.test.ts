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
        username: "a",
        password: "aaaaaaaa",
        email: "a@a.com",
        name: "a",
    };

    it("Register", async () => {
        const agent = supertest(app);
        const res = await agent.post("/auth/register").send(USER);
        expect(res.status).to.equal(201);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("username");
        expect(res.body).to.have.property("email");
        expect(res.body).to.have.property("name");
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
            .send({ username: USER.username, password: USER.password });
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("token");
    });

    it("Login bad password", async () => {
        const agent = supertest(app);
        await agent.post("/auth/register").send(USER);
        const res = await agent
            .post("/auth/login")
            .send({ username: USER.username, password: "abcdefgh" });
        expect(res.status).to.equal(401);
    });

    it("Session without token", async () => {
        const agent = supertest(app);
        const res = await agent.get("/auth/session").send();
        expect(res.status).to.equal(401);
    });

    it("Session with incorrect token", async () => {
        const agent = supertest(app);
        const token = await registerAndLogin(USER);
        const res = await agent
            .get("/auth/session")
            .set("Authorization", `Bearer ${token}a`)
            .send();
        expect(res.status).to.equal(403);
    });

    it("Session with token", async () => {
        const agent = supertest(app);
        const token = await registerAndLogin(USER);
        const res = await agent
            .get("/auth/session")
            .set("Authorization", `Bearer ${token}`)
            .send();
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("username");
        expect(res.body).to.have.property("email");
        expect(res.body).to.have.property("name");
    });

    it("Logout", async () => {
        const agent = supertest(app);
        const token = await registerAndLogin(USER);
        const res = await agent
            .post("/auth/logout")
            .set("Authorization", `Bearer ${token}`)
            .send();
        expect(res.status).to.equal(200);

        const session = await agent
            .get("/auth/session")
            .set("Authorization", `Bearer ${token}`)
            .send();
        expect(session.status).to.equal(403);
    });
});
