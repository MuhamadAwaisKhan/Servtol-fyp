import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User access granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User provisional access granted');
    } else {
      print('User access denied');
    }
  }

  Future<void> uploadFcmToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print('getToken:: $token');
        await firebaseFirestore.collection('users').doc(_currentUser!.uid).set(
            {
              'notificationToken': token,
              'email': _currentUser.email,
            },
            SetOptions(
                merge: true)); // Use merge to avoid overwriting existing fields
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('OnTokenRefresh:: $newToken');
        await firebaseFirestore.collection('users').doc(_currentUser!.uid).set({
          'notificationToken': newToken,
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error uploading FCM token: ${e.toString()}');
    }
  }

  Future<void> initLocalNotification() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          ' channel_id',
           ' Channel Name',
            channelDescription: 'Your channel description',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker');
    int notificationId = 1;

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      'High Importance Notifications',
      importance: Importance.max,
    );

  const  NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No title', // Handle null title
      message.notification?.body ?? 'No body', // Handle null body
      notificationDetails,
      payload: 'Not Present',
    );
  }
}
