import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/src/ui.dart';

/// Actions
enum RouteAction {
  PUSH,
  POP,
  POPALL,
  POPALL_SESSION,
  DIALOG_POPALL_SESSION,
  REPLACE
}

/// Router arguemnts
class RouteArgs {
  /// Name of route
  final String name;

  /// Action to take
  final RouteAction action;

  RouteArgs({this.name, this.action = RouteAction.PUSH});
}

/// Defines routes and transitions
class BroccoliRouter {
  // About
  static const String about = "/about";
  static const String acknowledgements = "/about/acknowledgements";

  // Auth/user
  static const String root = "/home";
  static const String auth = "/auth";
  static const String join = "/join";
  static const String profile = "/profile";
  static const String profilePromoting = "/profile/promoting";

  // Quiz pages
  static const String takeQuiz = "/take_quiz";
  static const String manageQuiz = "/manage_quiz";

  // Session
  static const String sessionLobby = "/session/lobby";
  static const String sessionQuestion = "/session/question";
  static const String sessionLeaderboard = "/session/leaderboard";

  // Group
  static const String sessionStart = "/session/start/quiz/:id";
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

    // Join (set name)
    router.define(join, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return NamePrompt();
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

    // Quiz question
    router.define(quizQuestion, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      final args = context.settings.arguments as QuestionArguments;
      return QuestionCreate(args.question, args.questionIndex);
    }));

    // Quiz with ID
    router.define(quiz, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      int quizId =
          params["id"][0].length > 0 ? int.parse(params["id"][0]) : null;
      return QuizCreate(quizId: quizId);
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
      return StartQuiz(int.parse(params["id"][0]));
    }));

    // Profile
    router.define(profile, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return ProfileMain();
    }), transitionType: TransitionType.inFromLeft);

    // Register account (in profile)
    router.define(profilePromoting, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return ProfilePromoting();
    }));
  }
}
