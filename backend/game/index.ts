import { json } from 'sequelize';
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

        socket.on('joinQuiz', (content: any) => {
            console.log(socket.handshake);

        });

        return next();
    })


    namespace = socketIO.of('/');
}
