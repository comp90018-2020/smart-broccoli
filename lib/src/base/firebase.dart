import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_broccoli/src/base/firebase_messages.dart';
import 'package:smart_broccoli/src/base/firebase_session_handler.dart';
import 'package:smart_broccoli/src/base/pubsub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationContent {
  final String type;
  final Object data;
  NotificationContent._internal(this.type, this.data);
  factory NotificationContent.fromJson(Map<String, dynamic> json) =>
      NotificationContent._internal(json['type'], json['data']);
}

class FirebaseNotification {
  // Firebase messaging instance
  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // Instanse used to show the notification when app is foreground
  LocalNotification localNotification;

  FirebaseNotification._internal(LocalNotification localNotification) {
    // Request notification permissions
    _requestPermission();
    // Listen on notification when app is in foreground
    _onForegroudMessage();
    // Listen on notification when app is in background
    _onBackgroudMessage();
  }

  static FirebaseNotification _singleton;

  static initialise(LocalNotification localNotification) async {
    _singleton = FirebaseNotification._internal(localNotification);
  }

  factory FirebaseNotification() {
    if (_singleton == null) throw Exception("Not initialised");
    return _singleton;
  }

  /// Get firebase token
  Future<String> getToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  /// Request permissions. May not work on iOS
  void _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void _onForegroudMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // If notification contains data
      if (message.data != null) {
        log(message.data.toString(), name: "Firebase");
        String type = message.data['type'];
        String data = message.data['data'];

        // Publish topics
        if (type == "SESSION_START") {
          // A quiz recommendation,
          // data like quizId will be found in data, same as below
          SessionStart start = SessionStart.fromJson(jsonDecode(data));
          int quizId = start.quizId;
          PubSub().publish(PubSubTopic.SESSION_START, arg: quizId);
        } else if (type == "SESSION_ACTIVATED")
          // Session has been activated
          PubSub().publish(PubSubTopic.SESSION_ACTIVATED, arg: data);
        else if (type == "QUIZ_UPDATE")
          // Quiz has been changed
          PubSub().publish(PubSubTopic.QUIZ_UPDATE, arg: data);
        else if (type == "QUIZ_DELETE")
          // Quiz has been deleted
          PubSub().publish(PubSubTopic.QUIZ_DELETE, arg: data);
        else if (type == "QUIZ_CREATE")
          // Quiz has been created
          PubSub().publish(PubSubTopic.QUIZ_CREATE, arg: data);
        else if (type == "GROUP_MEMBER_UPDATE")
          // Group members have changed
          PubSub().publish(PubSubTopic.GROUP_MEMBER_CHANGE, arg: data);
        else if (type == "GROUP_UPDATE")
          // Group has changed
          PubSub().publish(PubSubTopic.GROUP_UPDATE, arg: data);
        else if (type == "GROUP_DELETE")
          // Group has been deleted
          PubSub().publish(PubSubTopic.GROUP_DELETE, arg: data);
      }

      // When app is on foreground, this is needed to show notification
      if (message.notification != null) {
        localNotification.displayNotification('${message.notification.title}',
            message.notification.body, message.data['data']);
      }
    });
  }

  void _onBackgroudMessage() {
    // Background service
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  // Notification will show automatically, do not have to use LocalNotification
  // However there might be an innegligible delay
}

class LocalNotification {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const CHANNEL_ID = 'SmartBroccoliChannelID';
  static const CHANNEL_NAME = 'SmartBroccoliChannel';
  static const CHANNEL_DESC = 'Notification channel of SmartBroccoli';

  LocalNotification() {
    _initialise();
  }

  void _initialise() async {
    // Create notification settings with icon on android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icon');

    // Create notification settings on iOS
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
            onDidReceiveLocalNotification: didReceiveLocalNotification);
    // Create notification settings on MacOS
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    // Initial settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    // Initialise
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    // Ask for permissions
    _askForApplePermissions();
  }

  Future didReceiveLocalNotification(
      int a, String b, String c, String d) async {
    // Required in documentation
  }

  Future selectNotification(String data) async {
    SessionStart start = SessionStart.fromJson(jsonDecode(data));
    int quizId = start.quizId;
    FirebaseSessionHandler().setSessionStartMessage(start);
    PubSub().publish(PubSubTopic.SESSION_START, arg: quizId);
  }

  void _askForApplePermissions() async {
    /// iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    /// MacOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void displayNotification(String title, String body, String data) async {
    // Set notificaiton
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(CHANNEL_ID, CHANNEL_NAME, CHANNEL_DESC,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    // Show notication
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: data);
  }
}
