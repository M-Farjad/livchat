import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart.';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../constants/constants.dart';
import '../helper/dialogs.dart';
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
  //!for storing All users
  List<ChatUser> _list = [];
  //!for storing searched items
  final List<ChatUser> _searchlist = [];
  //!for storing search status
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //!For Updating User Status according to Lifecycle events
    //resumed - Active or online
    //paused - InActive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('paused')) {
          APIs.updateActiveStatus(false);
        }
        if (message.toString().contains('resumed')) {
          APIs.updateActiveStatus(true);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //!if Search is on then back button simply close the search !the whole app
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(CupertinoIcons.home),
              onPressed: () {},
            ),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email, ...',
                    ),
                    autofocus: true,
                    //?When Search text changes then update searchlist
                    onChanged: (value) {
                      //?Search Logic
                      _searchlist.clear();
                      for (var i in _list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchlist.add(i);
                        }
                        setState(() {
                          _searchlist;
                        });
                      }
                    },
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                  )
                : const Text("Livchat"),
            actions: [
              //Search User button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: APIs.me)),
                  );
                },
                icon: const Icon(Icons.more_vert),
              )
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                _showAddContactDialog();
              },
              child: const Icon(Icons.add_reaction_outlined),
            ),
          ),
          body: SafeArea(
              child: StreamBuilder(
            //get id of only known contacts
            stream: APIs.getMyContactsID(),
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
                  return StreamBuilder(
                    //get onlt those users whose id is provided
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //!if data is loading
                        // // if data is small then it will be loaded immediately
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const Center(
                              child: CircularProgressIndicator());
                        //!if data is loaded
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              itemCount: _isSearching
                                  ? _searchlist.length
                                  : _list.length,
                              padding: EdgeInsets.symmetric(
                                  vertical: mq.height * 0.01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ChatUserCard(
                                    user: _isSearching
                                        ? _searchlist[index]
                                        : _list[index]);
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
                  );
              }
            },
          )),
        ),
      ),
    );
  }

  void _showAddContactDialog() {
    String email = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(CupertinoIcons.person_add, size: 28, color: kPrimaryColor),
            const Text('  Add Contact'),
          ],
        ),
        content: TextFormField(
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'email@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: kPrimaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          maxLines: null,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            // color: kLightPrimaryColor,
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: kPrimaryColor,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              // APIs.updateMessage(widget.message, updatedMessage);
              Navigator.pop(context);
              if (email.isNotEmpty) {
                await APIs.addNewContact(email).then((value) {
                  if (!value) {
                    Dialogs.showSnackbar(context, 'User Does not Exist');
                  }
                });
              }
            },
            child: Text(
              'Add',
              style: TextStyle(
                fontSize: 16,
                color: kPrimaryColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
