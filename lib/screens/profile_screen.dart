import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart.';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import 'auth/login_screen.dart';

//!profile screen to show signed in user info
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final ChatUser user;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("User-Profile"),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () async {
              // _signOut() async {
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
              // }
            },
            label: const Text('Logout'),
            icon: const Icon(Icons.logout),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //for adding some space
              SizedBox(width: mq.width, height: mq.height * 0.03),
              ClipRRect(
                //!for removing unnecessary corners in images
                borderRadius: BorderRadius.circular(mq.height * 0.1),
                child: CachedNetworkImage(
                  width: mq.height * .2,
                  height: mq.height * .2,
                  fit: BoxFit.fill,
                  imageUrl: widget.user.image,
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              //for adding some space
              SizedBox(height: mq.height * 0.03),
              Text(widget.user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
              SizedBox(height: mq.height * 0.05),
              TextFormField(
                initialValue: widget.user.name,
                decoration: InputDecoration(
                  hintText: 'e.g Muhammad Farjad',
                  label: const Text('Name'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  prefixIcon: Icon(CupertinoIcons.person,
                      color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(height: mq.height * 0.02),
              TextFormField(
                initialValue: widget.user.about,
                decoration: InputDecoration(
                  hintText: 'e.g Feeling Great',
                  label: const Text('About'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  prefixIcon: Icon(CupertinoIcons.info_circle,
                      color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(height: mq.height * 0.05),
              //update profile button
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit,
                    size: 28,
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      minimumSize: Size(mq.width * 0.5, mq.height * .06)),
                  label: Text(
                    'Update',
                    style: TextStyle(fontSize: 16),
                  ))
            ],
          ),
        ));
  }
}
