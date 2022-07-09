import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:remindme/notifications.dart';
import 'globals.dart';

void main() {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'reminder',
        channelName: 'reminder',
        channelDescription: 'reminder',
        defaultColor: Colors.black,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (_) => const HomePage(),
        '/first': (_) => const Home(),
        '/second': (_) => const Second(),
        '/third': (_) => const Third()
      },
      initialRoute: '/',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return const Home();
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications()
      ..isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                      title: const Text('Notification'),
                      content: const Text(
                          'You have to allow notifications to get notifications'),
                      actions: [
                        TextButton(
                          child: const Text('Allow'),
                          onPressed: () {
                            AwesomeNotifications()
                                .requestPermissionToSendNotifications()
                                .then((value) => Navigator.pop(context));
                          },
                        ),
                        TextButton(
                          child: const Text('Don\'t Allow'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ]));
        }
      })
      ..dismissedStream.listen(
        (event) {
          AwesomeNotifications().decrementGlobalBadgeCounter();
          print(event);
        },
      )
      ..actionStream.listen((event) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Action')));
        AwesomeNotifications().decrementGlobalBadgeCounter();
        FlutterRingtonePlayer.play(
                android: AndroidSounds.ringtone, ios: IosSounds.alarm);
        if (event.buttonKeyPressed == '1') {
          FlutterRingtonePlayer.stop();
          showSnackBar('paused', context);
        }
      })
      ..createdStream.listen((event) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Notification created on ${event.channelKey}'),
        ));
      })
      ..displayedStream.listen((event) {
         FlutterRingtonePlayer.play(
                android: AndroidSounds.ringtone, ios: IosSounds.alarm);
        print('displayed');
      });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      globals.isBackground = null;
    } else {
      globals.isBackground = state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive;
    }
  }

  @override
  void dispose() {
    AwesomeNotifications()
      ..actionSink.close()
      ..createdSink.close()
      ..dismissedSink.close()
      ..displayedSink.close()
      ..dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const TextButton(
                onPressed: createImmediateNotification, child: Text('play')),
            TextButton(
                onPressed: onRepeatButtonPressed, child: const Text('Repeat')),
            const TextButton(
                onPressed: clearNotifications,
                child: Text('clear notifications')),
            TextButton(
                onPressed: () => createScheduledNotification(context),
                child: const Text('Notify')),
          ],
        ),
      ),
    );
  }

  void onRepeatButtonPressed() async {
    final timeofDay = await showDialog(
        context: context,
        builder: (_) => TimePickerDialog(
              initialTime: TimeOfDay.now(),
            ));
  }
}

class Third extends StatelessWidget {
  const Third({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.red,
    );
  }
}

class Second extends StatelessWidget {
  const Second({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
    );
  }
}
