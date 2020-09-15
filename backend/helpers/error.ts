/**
 * Error type with status
 * https://stackoverflow.com/questions/41102060
 */
class ErrorStatus extends Error {
    status: number;
    payload: any;

    constructor(message: string, status: number, payload: any = undefined) {
        super(message);
        this.status = status;
        this.payload = payload;

        // Set the prototype explicitly.
        Object.setPrototypeOf(this, ErrorStatus.prototype);
    }
}

export default ErrorStatus;
