import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_broccoli/src/base/pubsub.dart';

class FirebaseNotification {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;

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
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      const quizId = 1;
      PubSub().publish(PubSubTopic.NOTIFICATION, arg: quizId);
      if (message.notification != null) {
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
  print("Handling a background message: ${message.messageId}");
}
