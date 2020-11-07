import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_broccoli/src/base/pubsub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationContent {
  final PubSubTopic type;
  final Object data;
  NotificationContent._internal(this.type, this.data);
  factory NotificationContent.fromJson(Map<String, dynamic> json) =>
      NotificationContent._internal(json['type'], json['data']);
}

class FirebaseNotification {
  // Firebase messaging instance
  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // Instanse used to show the notification when app is foreground
  LocalNotification localNotification = LocalNotification();

  static final FirebaseNotification _singleton =
      FirebaseNotification._internal();

  FirebaseNotification._internal() {
    // Request notification permissions
    _requestPermisison();
    // Listen on notification when app is in foreground
    _onForegroudMesseage();
    // Listen on notification when app is in background
    _onBackgroudMesseage();
  }

  factory FirebaseNotification() {
    return _singleton;
  }

  /// Get firebase token
  Future<String> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  /// Request permissions. May not work on iOS
  void _requestPermisison() async {
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

  void _onForegroudMesseage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // If notification contains data
      if (message.data != null) {
        // Extract data
        NotificationContent content =
            NotificationContent.fromJson(message.data);

        if (content.type == PubSubTopic.QUIZ_RECOMMENDATION)
          // A quiz recommendation,
          // data like quizId will be found in content.data, same as below
          PubSub().publish(PubSubTopic.QUIZ_RECOMMENDATION, arg: content.data);
        else if (content.type == PubSubTopic.GROUP_CHANGE)
          // Group has been changed
          PubSub().publish(PubSubTopic.GROUP_CHANGE, arg: content.data);
        else if (content.type == PubSubTopic.QUIZ_CHANGE)
          // Quiz has been changed
          PubSub().publish(PubSubTopic.QUIZ_CHANGE, arg: content.data);
        else if (content.type == PubSubTopic.GENERAL_CHANGE)
          // General changes, this is for extension
          PubSub().publish(PubSubTopic.GENERAL_CHANGE, arg: content.data);
      }

      // When app is on foreground, this is needed to show notification
      if (message.notification != null) {
        localNotification.displayNotification(
            '${message.notification.title}', message.notification.body);
      }
    });
  }

  void _onBackgroudMesseage() {
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

  Future selectNotification(String payload) async {
    // May use
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

  void displayNotification(String title, String body) async {
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
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }
}
