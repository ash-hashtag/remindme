import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
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
    return FutureBuilder<bool>(
        future: delay(),
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            return const Home();
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
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
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
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
    });
    AwesomeNotifications().actionStream.listen((event) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Action')));

      Navigator.pushNamed(context, '/third');
    });
    AwesomeNotifications().createdStream.listen((event) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Notification created on ${event.channelKey}'),
      ));
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
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().createdSink.close();
    AwesomeNotifications().dispose();
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
            TextButton(
                onPressed: () => Navigator.pushNamed(context, '/second'),
                child: const Text('Second')),
            const TextButton(
                onPressed: clearNotifications,
                child: Text('clear notifications')),
            const TextButton(
                onPressed: createRepeatNotification, child: Text('Notify')),
          ],
        ),
      ),
    );
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
