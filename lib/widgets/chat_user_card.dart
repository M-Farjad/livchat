import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  final ChatUser user;
  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.lightGreen.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.01, vertical: 4),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          //user image
          leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
          //user name
          title: Text(widget.user.name),
          //user Last message
          subtitle: Text(widget.user.about, maxLines: 1),
          //user Last message time
          trailing:
              const Text('12:00 PM', style: TextStyle(color: Colors.black54)),
        ),
      ),
    );
  }
}
