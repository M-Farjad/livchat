import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome to Livchat"),
      ),
      body: Stack(
        children: [
          Positioned(
            top: mq.height * 0.15,
            width: mq.width * 0.7,
            left: mq.width * 0.15,
            child: Image.asset('assets/images/social-media.png'),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width * 0.9,
            left: mq.width * 0.05,
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          ),
        ],
      ),
    );
  }
}
