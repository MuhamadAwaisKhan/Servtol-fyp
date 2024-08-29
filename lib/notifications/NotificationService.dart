import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // Future<void> setupFirebaseMessaging() async {
  //   // Request necessary permissions from the user (iOS/Android 13+).
  //   await FirebaseMessaging.instance.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  //
  //   // Handle foreground messages
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print("Handling a foreground message: ${message.messageId}");
  //     _showNotification(message);
  //   });
  //
  //   // Handle background messages
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  //   // Handle messages that opened the app
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print("Handling a message that opened the app: ${message.messageId}");
  //     // Here, you can navigate to a specific screen, for example
  //   });
  // }
  //
  // static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   print("Handling a background message: ${message.messageId}");
  // }
  //
  // void _showNotification(RemoteMessage message) {
  //   // Display a notification in the app using Flutter local notification or similar.
  //   print('Message also contained a notification: ${message.notification?.title}, ${message.notification?.body}');
  // }
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  void requestnotificationpermission() async{
NotificationSettings settings =await messaging.requestPermission(
  alert: true,
      badge: true,
      sound: true,
  announcement: true,
  carPlay: true,
  criticalAlert: true,
  provisional: true,
);
if(settings.authorizationStatus ==AuthorizationStatus.authorized){
print('user access granted');
}else if(settings.authorizationStatus ==AuthorizationStatus.provisional){
  print('user provisional access granted');
} else {
  print('user access denied');
}
  }
}
