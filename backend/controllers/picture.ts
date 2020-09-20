import fs from "fs";
import Picture from "../models/picture";
import path from "path";

// Get picture by Id
const getPictureById = async (pictureId: number) => {
    return await Picture.findByPk(pictureId);
};

// Delete picture by Id
const deletePicture = async (pictureId: number) => {
    // Find, delete and destroy from DB
    const picture = await Picture.findByPk(pictureId);
    await deletePictureFromDisk(picture.destination);
    await picture.destroy();
};

// Insert a picture
const insertPicture = async (file: any) => {
    return await Picture.create({
        destination: file.destination,
        mimetype: file.mimetype,
        filename: file.filename,
    });
};

// Helper function to delete pictures and derivatives from disk
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
