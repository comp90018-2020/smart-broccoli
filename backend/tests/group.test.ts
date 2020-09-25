import supertest from "supertest";
import { expect } from "chai";
import app from "./index";
import rebuild from "./rebuild";
import { registerAndLogin } from "./helpers";
import {
    createGroup,
    getGroupAndVerifyRole,
    joinGroup,
} from "../controllers/group";

describe("Group", () => {
    beforeEach(async () => {
        await rebuild();
    });

    const USER = {
        email: "a@a.com",
        password: "aaaaaaaa",
        name: "a",
    };

    it("Session with token", async () => {
        const agent = supertest(app);
        const user = await registerAndLogin(USER);
        console.log(user);

        const group = await createGroup(user.id, "abc");
        // await joinGroup(user.id, "abc");
        await getGroupAndVerifyRole(user.id, group.id, "member");
    });
});
