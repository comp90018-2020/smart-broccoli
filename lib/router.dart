import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/src/ui.dart';

/// Actions
enum RouteAction { PUSH, POPALL, REPLACE }

/// Router arguemnts
class RouteArgs {
  /// Name of route
  final String routeName;

  /// Action to take
  final RouteAction routeAction;

  RouteArgs(this.routeName, {this.routeAction = RouteAction.PUSH});
}

/// Defines routes and transitions
class BroccoliRouter {
  // About
  static const String about = "/about";
  static const String acknowledgements = "/about/acknowledgements";

  // Auth/user
  static const String root = "/home";
  static const String auth = "/auth";
  static const String profile = "/profile";

  // Quiz pages
  static const String takeQuiz = "/take_quiz";
  static const String manageQuiz = "/manage_quiz";

  // Session
  static const String sessionLobby = "/session/lobby";
  static const String sessionQuestion = "/session/question";
  static const String sessionLeaderboard = "/session/leaderboard";
  static const String sessionStart = "/session/start";

  // Group
  static const String group = "/group/:id";
  static const String groupHome = "/group/home";
  static const String groupCreate = "/group/create";

  // Quiz editor
  static const String quiz = "/quiz/:id";
  static const String quizQuestion = "/quiz/question";
  static const String groupCreateQuiz = "/group/:id/quiz";

  /// Router
  final FluroRouter router;

  /// Constructor
  BroccoliRouter() : this.router = FluroRouter() {
    configureRoutes(router);
  }

  /// Route configuration
  void configureRoutes(FluroRouter router) {
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
      return GroupMain(int.parse(params["id"][0]));
    }));

    // Create quiz for specific group
    router.define(groupCreateQuiz, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return QuizCreate(groupId: int.parse(params["id"][0]));
    }));

    // Quiz
    router.define(quiz, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return QuizCreate(
          quizId: params["id"].length > 0 ? int.parse(params["id"][0]) : null);
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

    // Session start
    router.define(sessionStart, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return StartQuiz();
    }));

    // Profile
    router.define(profile, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return ProfileMain();
    }), transitionType: TransitionType.inFromLeft);
  }
}
