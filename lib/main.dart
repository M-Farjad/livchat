import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

late Size mq;

void main() {
  runApp(const MyApp());
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
      home: const LoginScreen(),
    );
  }
}
