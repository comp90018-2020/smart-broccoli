import fs from "fs";
import Picture from "../models/picture";
import path from "path";
import { Transaction } from "sequelize";

/**
 * Get picture by ID.
 * @param pictureId
 */
const getPictureById = async (pictureId: number) => {
    return await Picture.findByPk(pictureId);
};

/**
 * Delete picture by ID.
 * @param pictureId
 */
const deletePicture = async (pictureId: number, transaction?: Transaction) => {
    // Find, delete and destroy from DB
    const picture = await Picture.findByPk(pictureId, {
        attributes: ["id", "destination"],
    });
    // Already deleted
    if (!picture) {
        return;
    }
    await deletePictureFromDisk(picture.destination);
    await picture.destroy({ transaction });
};

/**
 * Insert a picture into db.
 * @param file Metadata about file
 */
const insertPicture = async (transaction: Transaction, file: any) => {
    return await Picture.create(
        {
            destination: file.destination,
            mimetype: file.mimetype,
            filename: file.filename,
        },
        { transaction }
    );
};

/**
 * Deletes a file from disk.
 * @param filePath Path of file
 */
const deletePictureFromDisk = (filePath: string) => {
    const dirname = path.dirname(filePath);
    const files = fs.readdirSync(dirname, "ascii");
    return Promise.all(
        files.map((file) => {
            if (path.basename(file) === path.basename(filePath)) {
                fs.unlink(file, () => {
                    return Promise.resolve();
                });
            }
            return Promise.resolve();
        })
    );
};

export { insertPicture, deletePicture, getPictureById };
