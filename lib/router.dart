import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/src/ui.dart';
import 'package:smart_broccoli/src/ui/profile/profile_main.dart';

/// Defines routes and transitions
class Routes {
  static String root = "/home";
  static String auth = "/auth";
  static String takeQuiz = "/take_quiz";
  static String manageQuiz = "/manage_quiz";
  static String sessionLobby = "/session/lobby";
  static String sessionQuestion = "/session/question";
  static String sessionLeaderboard = "/session/leaderboard";
  static String about = "/about";
  static String acknowledgements = "/about/acknowledgements";
  static String group = "/group/:id";
  static String groupHome = "/group/home";
  static String groupCreate = "/group/create";
  static String quiz = "/quiz";
  static String quizQuestion = "/quiz/question";
  static String profile = "/profile";

  /// Static router
  static FluroRouter router;

  /// Route configuration
  static void configureRoutes(FluroRouter router) {
    // Root
    router.define(root, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return InitialRouter();
    }));

    // Auth
    router.define(auth, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return AuthScreen();
    }));

    // Take quiz
    router.define(takeQuiz, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return TakeQuiz();
    }), transitionType: TransitionType.inFromLeft);

    // Manage quiz
    router.define(manageQuiz, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return ManageQuiz();
    }), transitionType: TransitionType.inFromLeft);

    // About
    router.define(about, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return AboutPage();
    }), transitionType: TransitionType.inFromLeft);

    // Acknowledgements
    router.define(acknowledgements, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return AcknowledgementsPage();
    }));

    // Group create
    router.define(groupCreate, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return GroupCreate();
    }));

    // Group list
    router.define(groupHome, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return GroupList();
    }), transitionType: TransitionType.inFromLeft);

    // Group
    router.define(group, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return GroupMain();
    }));

    // Quiz
    router.define(quiz, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return QuizCreate();
    }));

    // Question
    router.define(quizQuestion, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return QuestionCreate();
    }));

    // Session question
    router.define(sessionQuestion, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return QuizQuestion();
    }));

    // Session lobby
    router.define(sessionLobby, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return QuizLobby();
    }));

    // Leaderboard
    router.define(sessionLeaderboard, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return QuizLeaderboard();
    }));

    // Profile
    router.define(profile, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return ProfileMain();
    }));
  }
}
