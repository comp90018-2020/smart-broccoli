import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin, createGroup, joinGroup } from "./helpers";

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

    it("Join and leave group", async () => {
        const agent = supertest(app);
        const user1 = await registerAndLogin(USER);
        const user2 = await registerAndLogin({ ...USER, email: "a@b.com" });
        const group = await createGroup(user1.id, "a");

        // Join
        const joinRes = await agent
            .post(`/group/join`)
            .set("Authorization", `Bearer ${user2.token}`)
            .send({ name: "a" });
        expect(joinRes.status).to.equal(200);
        expect(joinRes.body).to.have.property("id");
        expect(joinRes.body.Users);

        // Check members
        const groupRes = await agent
            .get(`/group/${group.id}`)
            .set("Authorization", `Bearer ${user1.token}`);
        expect(groupRes.status).to.equal(200);
        expect(groupRes.body.Users).have.lengthOf(2);
        expect(
            groupRes.body.Users.map((m: any) => m.role).sort()
        ).to.deep.equal(["member", "owner"]);

        // Leave
        const leaveRes = await agent
            .post(`/group/${group.id}/leave`)
            .set("Authorization", `Bearer ${user2.token}`);
        expect(leaveRes.status).to.equal(204);
    });

    it("Kick member", async () => {
        const agent = supertest(app);
        const user1 = await registerAndLogin(USER);
        const user2 = await registerAndLogin({ ...USER, email: "a@b.com" });
        const group = await createGroup(user1.id, "a");

        // Join
        await joinGroup(user2.id, "a");

        // Bad kick
        const badRes = await agent
            .post(`/group/${group.id}/member/kick`)
            .set("Authorization", `Bearer ${user2.token}`)
            .send({ memberId: user2.id });
        expect(badRes.status).to.equal(403);

        const res = await agent
            .post(`/group/${group.id}/member/kick`)
            .set("Authorization", `Bearer ${user1.token}`)
            .send({ memberId: user2.id });
        expect(res.status).to.equal(204);
    });

    it("Delete group", async () => {
        const agent = supertest(app);

        const user1 = await registerAndLogin(USER);
        const user2 = await registerAndLogin({ ...USER, email: "a@b.com" });
        const group = await createGroup(user1.id, "a");

        // Join
        await joinGroup(user2.id, "a");

        // Delete
        const res = await agent
            .delete(`/group/${group.id}`)
            .set("Authorization", `Bearer ${user1.token}`);
        expect(res.status).equal(204);
    });

    it("Get user profile picture", async () => {
        const agent = supertest(app);

        const user1 = await registerAndLogin(USER);
        const user2 = await registerAndLogin({ ...USER, email: "a@b.com" });
        await createGroup(user1.id, "a");

        // Before join
        const failRes = await agent
            .get(`/user/${user2.id}/profile/picture`)
            .set("Authorization", `Bearer ${user1.token}`);
        expect(failRes.status).to.equal(403);

        // Join
        await joinGroup(user2.id, "a");

        // After join
        const res = await agent
            .get(`/user/${user2.id}/profile/picture`)
            .set("Authorization", `Bearer ${user1.token}`);
        expect(res.status).to.equal(404);
    });
});
