import { io } from 'server';
import { Server, Namespace } from 'socket.io';

let namespace: Namespace;

export default (socketIO: Server) => {
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        console.log('connected');

        // Emit an event to client
        socket.emit('message', 'hi');

        // User send
        socket.on('message', (message: string) => {
            console.log(`user said ${message}`);
        });

        return next();
    })


    namespace = socketIO.of('/');
}
