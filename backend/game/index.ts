import { Server } from 'socket.io';
import { Conn, LiveQuiz } from './quiz';

export const handler:LiveQuiz = new LiveQuiz();

export default (socketIO: Server) => {
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        try{
            const conn: Conn = await handler.verifySocket(socket);
            // join & welcome
            handler.welcome(socket, conn);

            // answer
            socket.on('answer', (content: any) => {
                handler.answer(socket, content, conn);
            });

            // quit
            socket.on('quit', (content: any) => {
                handler.quit(socket, content, conn);
            });

            // start
            socket.on('start', (content: any) => {
                handler.start(socket, content, conn);
            });

            // abort
            socket.on('abort', (content: any) => {
                handler.abort(socket, content, conn);
            });

            // next question
            socket.on('next', (content: any) => {
                handler.nextQuestion(socket, conn);
            });

            // showBoard
            socket.on('showBoard', (content: any) => {
                handler.showBoard(socket, content, conn);
            });

        }
        catch(err){
            if(process.env.NODE_EVN === 'debug'){
                // https://stackoverflow.com/questions/18391212
                socket.send(JSON.stringify(err, Object.getOwnPropertyNames(err)));
            }
            socket.disconnect();
        };

        return next();
    })


}
