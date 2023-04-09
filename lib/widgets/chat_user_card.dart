import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

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
        child: const ListTile(
          //user image
          leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
          //user name
          title: Text('Demo User'),
          //user Last message
          subtitle: Text('Last user message', maxLines: 1),
          //user Last message time
          trailing: Text('12:00 PM', style: TextStyle(color: Colors.black54)),
        ),
      ),
    );
  }
}
