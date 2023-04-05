import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../main.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Welcome to Livchat"),
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(seconds: 3),
              top: mq.height * 0.15,
              width: mq.width * 0.7,
              // mq.width * 0.15
              right: _isAnimate ? mq.width * 0.15 : -mq.width * 0.3,
              child: Image.asset('assets/images/social-media.png'),
            ),
            Positioned(
              bottom: mq.height * 0.1,
              width: mq.width * 0.9,
              left: mq.width * 0.05,
              height: mq.height * 0.07,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  elevation: 1,
                ),
                icon: Image.asset(
                  'assets/images/google.png',
                  height: mq.height * 0.04,
                ),
                label: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(text: 'Log In with '),
                      TextSpan(
                          text: 'Google',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
