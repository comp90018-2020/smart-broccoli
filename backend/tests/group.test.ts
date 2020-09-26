import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin } from "./helpers";
import {
    deleteGroup,
    getGroup,
    getGroupAndVerifyRole,
    getGroups,
    joinGroup,
} from "../controllers/group";
import { createGroup } from "./helpers";

describe("Group", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };

    it("Create and get group", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);

        const createRes = await agent
            .post("/group")
            .set("Authorization", `Bearer ${user.token}`)
            .send({ name: "a" });
        expect(createRes.status).to.equal(201);
        expect(createRes.body).to.have.property("id");
        expect(createRes.body).to.have.property("name");
        expect(createRes.body.name).to.equal("a");

        const getRes = await agent
            .get("/group")
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(getRes.status).to.equal(200);
        expect(getRes.body).to.have.lengthOf(1);
        expect(getRes.body[0]).to.have.property("role");
        expect(getRes.body[0].role).to.equal("owner");

        const getGroupRes = await agent
            .get(`/group/${createRes.body.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send();
        expect(getGroupRes.status).to.equal(200);
        expect(getGroupRes.body).to.have.property("Users");
    });

    it("Update group name", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        const group = await createGroup(user.id, "a");

        const res = await agent
            .patch(`/group/${group.id}`)
            .set("Authorization", `Bearer ${user.token}`)
            .send({
                name: "b",
            });
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property("name");
        expect(res.body.name).to.equal("b");
    });

    it("Session with token", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        console.log(user);

        const group = await createGroup(user.id, "abc");
        // await joinGroup(user.id, "abc");
        await getGroupAndVerifyRole(user.id, group.id, "member");

        const groups = await getGroups(user.id);
        console.log(groups);
        console.log(await getGroup(user.id, group.id));
        await deleteGroup(group.id);
    });
});
