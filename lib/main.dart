import 'package:alarm_app/set_time.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:alarm/alarm.dart';

import 'MyHomePage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Alarm.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      routes: {
        '/home': (context) => const MyHomePage(),
        '/Second': (context) => const setTime(),
      },
      theme: ThemeData(fontFamily: "Mostin"),
      initialRoute: '/home',
    );
  }
}

