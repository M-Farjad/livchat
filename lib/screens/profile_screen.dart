import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart.';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livchat/helper/dialogs.dart';

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
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("User-Profile")),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () async {
              // _signOut() async {
              Dialogs.showProgressbar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding progress dialog
                  Navigator.pop(context);
                  //for moving Home Screen
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });

              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: (_) => const LoginScreen()));
              // }
            },
            label: const Text('Logout'),
            icon: const Icon(Icons.logout),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //for adding some space
                SizedBox(width: mq.width, height: mq.height * 0.03),
                Stack(
                  children: [
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
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        onPressed: () {
                          _showBottonSheet();
                        },
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: Icon(
                          Icons.edit_note_sharp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
                //for adding some space
                SizedBox(height: mq.height * 0.03),
                Text(widget.user.email,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
                SizedBox(height: mq.height * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
                  child: TextFormField(
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : '*Required',
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
                ),
                SizedBox(height: mq.height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
                  child: TextFormField(
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : '*Required',
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
                ),
                SizedBox(height: mq.height * 0.05),
                //update profile button
                ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, 'Profile Updated ... !');
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 28,
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        minimumSize: Size(mq.width * 0.5, mq.height * .06)),
                    label: const Text(
                      'Update',
                      style: TextStyle(fontSize: 16),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottonSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return ListView(
            padding: EdgeInsets.symmetric(vertical: mq.height * .03),
            shrinkWrap: true,
            children: [
              const Text(
                'Pick Profile Picture',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: mq.height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    onPressed: () {},
                    child: Image.asset('assets/images/camera.png'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    onPressed: () {},
                    child: Image.asset('assets/images/add-image.png'),
                  ),
                ],
              )
            ],
          );
        });
  }
}
