import { Server } from 'socket.io';
import { Quiz } from './quiz';
import { Conn } from './session';

export const handler: Quiz = new Quiz();

export default (socketIO: Server) => {
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        try {
            const conn: Conn = await handler.verifySocket(socket);
            console.log(conn);

            // join & welcome
            handler.welcome(socketIO, socket, conn);

            // answer
            socket.on('answer', (content: any) => {
                handler.answer(socketIO, content, conn);
            });

            // quit
            socket.on('quit', () => {
                handler.quit(socketIO, socket, conn);
            });

            // start
            socket.on('start', () => {
                handler.start(socketIO, socket, conn);
            });

            // abort
            socket.on('abort', () => {
                handler.abort(socketIO, socket, conn);
            });

            // next question
            socket.on('next', () => {
                handler.next(socketIO, socket, conn);
            });

            // showBoard
            socket.on('showBoard', () => {
                handler.showBoard(socketIO, conn);
            });

        }
        catch (err) {
            if (process.env.NODE_EVN === 'debug') {
                // https://stackoverflow.com/questions/18391212
                socket.send(JSON.stringify(err, Object.getOwnPropertyNames(err)));
            }
            socket.disconnect();
        };

        return next();
    })


}
