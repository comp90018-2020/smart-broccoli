import multer from "multer";
import crypto from "crypto";
import path from "path";
import fs from "fs";
import sharp from "sharp";
import { Request } from "express";

export default class CustomStorage implements multer.StorageEngine {
    private destination: string;
    private imageProcessor: (path: string) => Promise<void>;

    constructor(opts?: {
        directoryPrefix: string;
        imageProcessor: (path: string) => Promise<void>;
    }) {
        this.imageProcessor = opts.imageProcessor;

        // Create directory if not exists
        if (!opts.directoryPrefix) {
            throw new Error("Bad destination");
        }
        this.destination = `${process.cwd()}/uploads/${opts.directoryPrefix}`;
        if (!fs.existsSync(this.destination)) {
            fs.mkdirSync(this.destination);
        }
    }

    // Random filename
    private getFilename(): Promise<string> {
        return new Promise((resolve, reject) => {
            crypto.pseudoRandomBytes(16, function (err, raw) {
                if (err) return reject(err);
                return resolve(raw.toString("hex"));
            });
        });
    }

    _handleFile(
        req: Request,
        file: Express.Multer.File,
        cb: (error?: any, info?: Partial<Express.Multer.File>) => void
    ) {
        // Get dest
        const dest = this.destination;

        this.getFilename()
            .then((filename: string) => {
                // Write file
                const filePath = path.join(dest, filename);
                const outStream = fs.createWriteStream(filePath);
                file.stream.pipe(outStream);

                outStream.on("error", cb);
                outStream.on("finish", async () => {
                    try {
                        await this.imageProcessor(filePath);
                        cb(undefined, {
                            destination: dest,
                            filename: filename,
                            path: filePath,
                            size: outStream.bytesWritten,
                        });
                    } catch (err) {
                        // Remove file before giving error
                        file.path = filePath;
                        this._removeFile(req, file, () => {
                            return cb(err);
                        });
                    }
                });
            })
            .catch((err: Error) => {
                console.error("Cannot get filename");
                return cb(err);
            });
    }

    _removeFile(
        req: Request,
        file: Express.Multer.File,
        callback: (error: Error) => void
    ) {
        const filePath = file.path;

        delete file.destination;
        delete file.filename;
        delete file.path;

        fs.unlink(`${filePath}_thumb`, (err: Error) => {
            fs.unlink(filePath, callback);
        });
    }
}

// Processes profile images
const profileImageProcessor = async (filePath: string) => {
    sharp.cache(false);
    const buf = await sharp(filePath).toBuffer();

    // Resize to 128x128
    await sharp(buf)
        .resize(128, 128, {
            fit: "contain",
            withoutEnlargement: true,
        })
        .jpeg({ quality: 100 })
        .toFile(`${filePath}_thumb`);
};
export { profileImageProcessor };
