import { io } from 'server';
import { Server, Namespace } from 'socket.io';
import { Quiz } from './quiz';

let namespace: Namespace;
const quiz = new Quiz();

export default (socketIO: Server) => {
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        console.log('connected');

        // Emit an event to client
        socket.emit('message', JSON.stringify({"serverTs": Date.now()}));

        socket.on('quiz', (content: string) => {
            let ret: boolean;
            let response: string;
            [ret, response] = quiz.handle(content);
            socket.emit('quiz', response);
            if (!ret) {
                socket.disconnect();
            }
        });

        return next();
    })


    namespace = socketIO.of('/');
}
