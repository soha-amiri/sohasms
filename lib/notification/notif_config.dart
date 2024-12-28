import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationConfig {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final StreamController<NotificationResponse> selectNotificationStream =
      StreamController<NotificationResponse>.broadcast();

  // initial
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static void notificationTapBackground(NotificationResponse response) {
    selectNotificationStream.add(response);
    // // ignore: avoid_print
    // print('notification(${notificationResponse.id}) action tapped: '
    //     '${notificationResponse.actionId} with'
    //     ' payload: ${notificationResponse.payload}');
    // if (notificationResponse.input?.isNotEmpty ?? false) {
    //   // ignore: avoid_print
    //   print(
    //       'notification action tapped with input: ${notificationResponse.input}');
    // }
    // Handle the action button tap
    if (response.payload != null) {
      print('Notification action tapped with payload: ${response.payload}');
    }
    if (response.actionId == 'disable') {
      print('Action 1 tapped');
    }
  }

  static Future showNotification(
    int id, {
    required String title,
    required String body,
    required String payload,
    required bool ongoing,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ongoing: ongoing,
            // actions: [
            //   AndroidNotificationAction('disable', 'غیرغعالسازی',
            //       showsUserInterface: true)
            // ],
            ticker: 'ticker');
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    // Generate a unique notification ID
    await _flutterLocalNotificationsPlugin
        .show(id ?? 0, title, body, notificationDetails, payload: payload);
  }

  static Future<void> cancelNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    print('notif canceled');
  }
}
