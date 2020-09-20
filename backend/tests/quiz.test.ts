import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin, createQuiz } from "./helpers";

describe("Authentication", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };

    it("Create quiz", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        const res = await agent
            .post("/quiz")
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(res.status).to.equal(201);
        expect(res.body).to.have.property("id");
        expect(res.body).to.have.property("title");
        expect(res.body).to.have.property("description");
    });

    it("Update quiz attributes", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const quiz = await createQuiz(user.id);

        const res = await agent
            .patch(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send({ title: "a", description: "b" });
        expect(res.status).to.equal(200);
        expect(res.body.title).to.equal("a");
        expect(res.body.description).to.equal("b");
    });

    it("Delete quiz", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const quiz = await createQuiz(user.id);

        const res = await agent
            .delete(`/quiz/${quiz.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(res.status).to.equal(200);
    });
});
