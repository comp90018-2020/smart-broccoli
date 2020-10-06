import { Server, Namespace } from 'socket.io';
import { LiveQuiz } from './quiz';



let namespace: Namespace;
const handler = new LiveQuiz();

export default (socketIO: Server) => {
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        if (handler.verifySocketConn(socket)) {
            // join & welcome
            handler.welcome(socket);

            // answer
            socket.on('answer', (content: any) => {
                handler.answer(socket, content);
            });

            // quit
            socket.on('quit', (content: any) => {
                handler.quit(socket, content);
            });

            // start
            socket.on('start', (content: any) => {
                handler.start(socket, content);
            });

            // abort
            socket.on('abort', (content: any) => {
                handler.abort(socket, content);
            });

            // next question
            socket.on('next', (content: any) => {
                handler.nextQuestion(socket, content);
            });

            // showBoard
            socket.on('showBoard', (content: any) => {
                handler.showBoard(socket, content);
            });

        } else {
            socket.disconnect();
        };

        return next();
    })


    namespace = socketIO.of('/');
}
