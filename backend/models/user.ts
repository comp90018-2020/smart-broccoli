import Sequelize from "sequelize";
import crypto from "crypto";

// Schema
const schema = {
    id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    password: { type: Sequelize.STRING, allowNull: false },
    email: { type: Sequelize.STRING, allowNull: false },
    name: { type: Sequelize.STRING, allowNull: true },
    picture: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
            model: {
                tableName: "Pictures",
            },
            key: "id",
        },
    },
};

interface UserAttributes {
    id?: number;
    password: string;
    email: string;
    name?: string;
    createdAt?: Date;
    updatedAt?: Date;
}

const ITERATIONS = 100000;
const ALGORITHM = "sha512";
const KEYLEN = 64;

class User extends Sequelize.Model<UserAttributes> implements UserAttributes {
    public password!: string;
    public email!: string;
    public name: string;
    public picture: number;

    public readonly id!: number;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;

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
                    try {
                        const hash = await hashPassword(user.password);
                        user.password = hash;
                    } catch (err) {
                        return Promise.reject(err);
                    }
                },
                // Hash password before update
                beforeUpdate: async (user: any) => {
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
