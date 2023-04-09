import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart.';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../main.dart';
import '../widgets/chat_user_card.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.home),
          onPressed: () {},
        ),
        title: const Text("Livchat"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () async {
            // _signOut() async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()));
            // }
          },
          child: const Icon(Icons.add_reaction_outlined),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: APIs.firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            final list = [];
            if (snapshot.hasData) {
              final data = snapshot.data?.docs;
              for (var i in data!) {
                log("Data: ${jsonEncode(i.data())}");
                list.add(jsonEncode(i.data()['name']));
              }
            }
            return ListView.builder(
              itemCount: list.length,
              padding: EdgeInsets.symmetric(vertical: mq.height * 0.01),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                // return const ChatUserCard();
                return Text('Name: ${list[index]}}');
              },
            );
          },
        ),
      ),
    );
  }
}
