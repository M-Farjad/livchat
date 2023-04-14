import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message_model.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});
  final ChatUser user;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar:
            AppBar(automaticallyImplyLeading: false, flexibleSpace: _appBar()),
        backgroundColor: Color.fromARGB(255, 227, 255, 228),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIs.getAllMessages(),
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
                      log('message: ${jsonEncode(data![0].data())}');
                      // _list = data
                      //         ?.map((e) => ChatUser.fromJson(e.data()))
                      //         .toList() ??
                      //     [];
                      _list.clear();
                      _list.add(MessageModel(
                          msg: 'Hello',
                          toID: 'xyz',
                          read: '',
                          type: Type.text,
                          fromID: APIs.user.uid,
                          sent: '12:00 AM'));
                      _list.add(MessageModel(
                          msg: 'Hii',
                          toID: APIs.user.uid,
                          read: '',
                          type: Type.text,
                          fromID: 'xyz',
                          sent: '12:05 AM'));
                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          itemCount: _list.length,
                          padding:
                              EdgeInsets.symmetric(vertical: mq.height * 0.01),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return MessageCard(message: _list[index]);
                          },
                        );
                      } else {
                        return const Center(
                            child: Text('Say Hii ... 🤭',
                                style: TextStyle(fontSize: 20)));
                      }
                  }
                },
              ),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          //Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.back),
            color: Theme.of(context).primaryColor,
          ),
          //User Profile Picture
          ClipRRect(
            //!for removing unnecessary corners in images
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              width: mq.height * .05,
              height: mq.height * .05,
              imageUrl: widget.user.image,
              fit: BoxFit.cover,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              const SizedBox(width: 2),
              const Text('Last seen not available',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * 0.025, vertical: mq.height * .01),
      child: Row(
        children: [
          //!Input Field & Buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //Icon Button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.emoji_emotions_outlined, size: 26),
                    color: Theme.of(context).primaryColor,
                  ),
                  //Expanded to specify TextField width
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Message ...',
                        hintStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  //Gallery Button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined, size: 26),
                    color: Theme.of(context).primaryColor,
                  ),
                  //Camera Button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined, size: 26),
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: mq.width * .02)
                ],
              ),
            ),
          ),
          //Message Send button
          MaterialButton(
            minWidth: 0,
            onPressed: () {},
            child: Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
            color: Theme.of(context).primaryColor,
            shape: CircleBorder(),
            padding:
                const EdgeInsets.only(bottom: 10, right: 5, left: 10, top: 10),
          )
        ],
      ),
    );
  }
}
