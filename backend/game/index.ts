import { json } from 'sequelize';
import { io } from 'server';
import { Server, Namespace } from 'socket.io';
import { Quiz } from './quiz';
import { jwtVerify } from "../helpers/jwt"

let secret: string = "aaa";

let namespace: Namespace;
const quiz = new Quiz();

export default (socketIO: Server) => {
    socketIO.use(async (socket, next) => {
        // check socket.handshake contents (authentication)
        console.log('connected');

        // Emit an event to client
        socket.emit('message', JSON.stringify({ "serverTs": Date.now() }));

        // activate quiz
        socket.on('activateQuiz', (content: any) => {
            try {
                jwtVerify(socket.handshake.query.token, secret);
            }
            catch (err) {
                console.error(err);
            }
        });

        // abort quiz
        socket.on('abortQuiz', (content: any) => {
            try {
                jwtVerify(socket.handshake.query.token, secret);
            }
            catch (err) {
                console.error(err);
            }
        });

        // join quiz
        socket.on('joinQuiz', (content: any) => {
            try {
                jwtVerify(socket.handshake.query.token, secret);
            }
            catch (err) {
                console.error(err);
            }
        });

        // start quiz
        socket.on('startQuiz', (content: any) => {
            try {
                jwtVerify(socket.handshake.query.token, secret);
            }
            catch (err) {
                console.error(err);
            }
        });

        // answer quiz
        socket.on('answerQuiz', (content: any) => {
            try {
                jwtVerify(socket.handshake.query.token, secret);
            }
            catch (err) {
                console.error(err);
            }
        });

        // next question
        socket.on('nextQuestion', (content: any) => {
            try {
                jwtVerify(socket.handshake.query.token, secret);
            }
            catch (err) {
                console.error(err);
            }
        });

        // show leader board
        socket.on('showLeaderBoard', (content: any) => {
            try {
                jwtVerify(socket.handshake.query.token, secret);
            }
            catch (err) {
                console.error(err);
            }
        });

        // end quiz
        socket.on('endQuiz', (content: any) => {
            try {
                jwtVerify(socket.handshake.query.token, secret);
            }
            catch (err) {
                console.error(err);
            }
        });
        
        return next();
    })


    namespace = socketIO.of('/');
}
