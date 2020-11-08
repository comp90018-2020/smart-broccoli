import sequelize from "../models";

export default async () => {
    await sequelize.truncate({
        force: true,
        cascade: true,
        truncate: true,
        restartIdentity: true,
    });
};
