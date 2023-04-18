import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash_screen.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //?Enter Full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  //!For setting orientation to portriat only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFireBase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livchat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 1,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 19),
          backgroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeFireBase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notifications',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log(result);
}
// Firebase token: 1//03Rrc0MOMm9KsCgYIARAAGAMSNwF-L9IrFNRA4W1ft9GBgkds-OCmsGsvn50K69yxzd8hC5xtVL4LSoIojXidkVRSeGExDqRrYOY 
// Platform  Firebase App Id
// web       1:384644475390:web:93d2adcb8a1adb2230b8af
// android   1:384644475390:android:35715e266803dd2430b8af
// ios       1:384644475390:ios:c523708332b9cfd530b8af