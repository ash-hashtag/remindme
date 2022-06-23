import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

Future<void> createRepeatNotification() async {
  await createScheduledNotification(null);
  // await AwesomeNotifications().createNotification(
  //   content: NotificationContent(
  //     id: 23,
  //     channelKey: 'reminder',
  //     title: 'Reminder',
  //     body: 'You asked for it',
  //   ),
  // );
}

Future<void> createScheduledNotification(TimeOfDay? timeOfDay) async {
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar.fromDate(date: DateTime.now().add(const Duration(seconds: 3))),
    content: NotificationContent(
      id: 24,
      channelKey: 'reminder',
      title: 'Reminder',
      body: 'You asked for it',
    ),);
}

void clearNotifications(){
  AwesomeNotifications().setGlobalBadgeCounter(0);
}
