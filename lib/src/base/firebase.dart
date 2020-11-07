import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_broccoli/src/base/pubsub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotification {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  LocalNotification localNotification = LocalNotification();

  /// Instance held locally
  static final FirebaseNotification _singleton =
      FirebaseNotification._internal();

  /// Internal constructor
  FirebaseNotification._internal() {
    _requestPermisison();
    _onForegroudMesseage();
    _onBackgroudMesseage();
  }

  factory FirebaseNotification() {
    return _singleton;
  }

  Future<String> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  void _requestPermisison() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  void _onForegroudMesseage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      const quizId = 1;
      PubSub().publish(PubSubTopic.NOTIFICATION, arg: quizId);
      if (message.notification != null) {
        localNotification.displayNotification(
            '${message.notification.title}', message.notification.body);
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  void _onBackgroudMesseage() {
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
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
            onDidReceiveLocalNotification: didReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    _askForApplePermissions();
  }

  Future didReceiveLocalNotification(
      int a, String b, String c, String d) async {
    print('didReceiveLocalNotification: $a, $b, $c, $d');
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: $payload');
    }
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
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(CHANNEL_ID, CHANNEL_NAME, CHANNEL_DESC,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }
}
