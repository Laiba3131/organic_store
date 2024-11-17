import 'package:ecomerance_app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseApi{
  final _firebaseMessaging= FirebaseMessaging.instance;

Future<void> initNotifications() async {
  await _firebaseMessaging.requestPermission();
  final FCMToken = await _firebaseMessaging.getToken();
  print('Token: $FCMToken');
}


void handleMessage(RemoteMessage? message) {
  if (message == null) return;
  navigatorKey.currentState?.pushNamed('/notificationPage', arguments: message);
}


  Future<void> initPushNotifications() async {
    await initNotifications();

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground: ${message.notification?.title}');
      // Handle or show notification manually if needed
    });
  }
}