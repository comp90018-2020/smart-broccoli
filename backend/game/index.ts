import { io } from 'server';
import { Server, Namespace } from 'socket.io';
import { LiveQuiz } from './quiz';



let namespace: Namespace;
const handler = new LiveQuiz();

export default (socketIO: Server) => {
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        console.log('connected');

        // Emit an event to client
        socket.emit('message', JSON.stringify({ "serverTs": Date.now() }));
        
        socket.on('message', (content:any) =>{
            console.log(typeof(content));
            console.log(content);
        });
            // activate quiz
            socket.on('activateQuiz', (content: any) => {
                handler.activeQuiz(socket, content);
            });

            // abort quiz
            socket.on('abortQuiz', (content: any) => {
                handler.abortQuiz(socket ,content);
            });

            // join quiz
            socket.on('joinQuiz', (content: any) => {
                handler.joinQuiz(socket, content);
            });

            // start quiz
            socket.on('startQuiz', (content: any) => {
                handler.startQuiz(socket, content);
            });

            // answer quiz
            socket.on('answerQuiz', (content: any) => {
                handler.answerQuiz(socket, content);
            });

            // next question
            socket.on('nextQuestion', (content: any) => {
                handler.nextQuestion(socket, content);
            });

            // show leader board
            socket.on('getLeaderBoard', (content: any) => {
                handler.getLeaderBoardQuiz(socket);
            });

            // end quiz
            socket.on('endQuiz', (content: any) => {
                handler.endQuiz(socket);
            });
    
        return next();
    })


    namespace = socketIO.of('/');
}
