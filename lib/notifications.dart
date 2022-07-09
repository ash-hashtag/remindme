import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

Future<void> createRepeatNotification(TimeOfDay timeOfDay) async {
  // await AwesomeNotifications().createNotification(
  //   content: NotificationContent(
  //     id: 23,
  //     channelKey: 'reminder',
  //     title: 'Reminder',
  //     body: 'You asked for it',
  //   ),
  // );
}

Future<void> createScheduledNotification(BuildContext context,
    {bool reminder = true}) async {
  final NOW = DateTime.now();
  final date = await showDatePicker(
      context: context,
      initialDate: DateTime(NOW.year, NOW.month, NOW.day),
      firstDate: DateTime(NOW.year, NOW.month, NOW.day),
      lastDate: DateTime.utc(3000));
  if (date == null) return;
  final time =
      await showTimePicker(context: context, initialTime: TimeOfDay.now());
  if (time != null) {
    date.add(Duration(hours: time.hour, minutes: time.minute));
  } else if (date.day == NOW.day &&
      date.month == NOW.month &&
      date.year == NOW.year) {
    showSnackBar('Pick Time', context);
  }
  String title = date.toString();
  final tc = TextEditingController();
  await showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: const Text('title'),
            actions: [
              TextField(
                controller: tc,
                decoration: InputDecoration(hintText: title),
              ),
              TextButton(
                  onPressed: () {
                    if (tc.text.isNotEmpty) title = tc.text;
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          ));
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar.fromDate(
        date: DateTime.now().add(const Duration(seconds: 3))),
    content: NotificationContent(
      id: 24,
      channelKey: 'reminder',
      title: 'Reminder',
      body: 'You asked for it',
    ),
  );
  // tc.dispose();
  await Future.delayed(const Duration(seconds: 1), tc.dispose);
}

void createImmediateNotification() async {
  await AwesomeNotifications().createNotification(
      schedule: NotificationCalendar.fromDate(
          date: DateTime.now().add(const Duration(seconds: 1))),
      content: NotificationContent(
        id: Random().nextInt(10),
        channelKey: 'reminder',
        title: 'Reminder',
        body: 'You asked for it',
      ),
      actionButtons: [
        NotificationActionButton(key: '0', label: 'dismiss'),
        NotificationActionButton(key: '1', label: 'stop'),
        NotificationActionButton(key: '2', label: 'later'),
      ]);
}

void clearNotifications() {
  AwesomeNotifications().setGlobalBadgeCounter(0);
}

void showSnackBar(String text, BuildContext context) =>
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
void playMusic() {
  FlutterRingtonePlayer.play(
      android: AndroidSounds.ringtone, ios: IosSounds.alarm, asAlarm: true);
}
