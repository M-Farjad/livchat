import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livchat/screens/auth/login_screen.dart';
import 'package:livchat/screens/home_screen.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   title: const Text("Welcome to Livchat"),
        // ),
        body: Stack(
          children: [
            Positioned(
              top: mq.height * 0.15,
              right: mq.width * 0.15,
              width: mq.width * 0.7,
              child: Image.asset('assets/images/chat.png'),
            ),
            Positioned(
              bottom: mq.height * 0.15,
              width: mq.width,
              child: const Text(
                'Made in Youngstr with ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
