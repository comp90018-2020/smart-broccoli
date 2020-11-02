import Sequelize, {
    BelongsToManyGetAssociationsMixin,
    HasOneGetAssociationMixin,
    HasOneSetAssociationMixin,
    Optional,
} from "sequelize";
import crypto from "crypto";
import {
    Group,
    NotificationSettings,
    SessionParticipant,
    Token,
    UserGroup,
    UserState,
} from "models";
import Picture from "./picture";

// Represents users
const schema: Sequelize.ModelAttributes = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    password: { type: Sequelize.STRING, allowNull: true },
    email: { type: Sequelize.STRING, allowNull: true },
    name: { type: Sequelize.STRING, allowNull: true },
    role: { type: Sequelize.ENUM("participant", "user"), allowNull: false },
    pictureId: {
        type: Sequelize.INTEGER,
        allowNull: true,
    },
};

interface UserAttributes {
    id: number;

    // Must have role
    role: string;

    // User attributes
    password?: string;
    email?: string;

    // Participant attributes
    name?: string;

    createdAt: Date;
    updatedAt: Date;
}
interface UserCreationAttributes
    extends Optional<UserAttributes, "id" | "createdAt" | "updatedAt"> {}

const ITERATIONS = 100000;
const ALGORITHM = "sha512";
const KEYLEN = 64;

class User
    extends Sequelize.Model<UserAttributes, UserCreationAttributes>
    implements UserAttributes {
    public password?: string;
    public email?: string;
    public name?: string;
    public role: string;
    public pictureId?: number;

    public readonly id!: number;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;

    public UserGroup?: UserGroup;
    public SessionParticipant?: SessionParticipant;
    public Picture?: Picture;

    public Tokens?: Token[];
    public UserState?: UserState;
    public NotificationSettings?: NotificationSettings;

    public getGroups!: BelongsToManyGetAssociationsMixin<Group>;
    public getPicture!: HasOneGetAssociationMixin<Picture>;

    static initialise(sequelize: Sequelize.Sequelize) {
        return super.init.call(this, schema, {
            sequelize,
            defaultScope: {
                attributes: { exclude: ["password"] },
            },
            indexes: [
                // Ensure that emails are unique
                {
                    name: "unique_email",
                    unique: true,
                    // @ts-ignore
                    fields: [sequelize.fn("lower", sequelize.col("email"))],
                },
            ],
            hooks: {
                // Hash password before creation
                beforeCreate: async (user: any) => {
                    if (user.role !== "user") return;

                    try {
                        const hash = await hashPassword(user.password);
                        user.password = hash;
                    } catch (err) {
                        return Promise.reject(err);
                    }
                },
                // Hash password before update
                beforeUpdate: async function (user: any) {
                    // If password is not changed
                    if (!user.password) {
                        return;
                    }

                    try {
                        const hash = await hashPassword(user.password);
                        user.password = hash;
                    } catch (err) {
                        return Promise.reject(err);
                    }
                },
            },
        });
    }

    verifyPassword = function (password: string): Promise<boolean> {
        return new Promise((resolve, reject) => {
            const salt = this.password.split(":")[0];
            crypto.pbkdf2(
                password,
                salt,
                ITERATIONS,
                KEYLEN,
                ALGORITHM,
                (err, derivedKey) => {
                    if (err) return reject(err);
                    return resolve(
                        `${salt}:${derivedKey.toString("hex")}` ===
                            this.password
                    );
                }
            );
        });
    };
}

// Hash password
const hashPassword = (password: string) => {
    // https://nodejs.org/api/crypto.html
    return new Promise((resolve, reject) => {
        const salt = crypto.randomBytes(16).toString("hex");
        crypto.pbkdf2(
            password,
            salt,
            ITERATIONS,
            KEYLEN,
            ALGORITHM,
            (err, derivedKey) => {
                if (err) return reject(err);
                return resolve(`${salt}:${derivedKey.toString("hex")}`);
            }
        );
    });
};

export default User;
