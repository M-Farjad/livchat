import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart.';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import 'auth/login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)),
              );
            },
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
          stream: APIs.getAllUsers(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              //!if data is loading
              // // if data is small then it will be loaded immediately
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              //!if data is loaded
              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                    [];
                if (list.isNotEmpty) {
                  return ListView.builder(
                    itemCount: list.length,
                    padding: EdgeInsets.symmetric(vertical: mq.height * 0.01),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatUserCard(user: list[index]);
                    },
                  );
                } else {
                  return const Center(
                      child: Text(
                    'No Connections found.',
                    style: TextStyle(fontSize: 20),
                  ));
                }
            }
          },
        ),
      ),
    );
  }
}
