import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

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
        onTap: () {
          //!For Navigating to ChatScreen
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: ListTile(
          //user image
          // leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),

          leading: ClipRRect(
            //!for removing unnecessary corners in images
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              width: mq.height * .055,
              height: mq.height * .055,
              imageUrl: widget.user.image,
              fit: BoxFit.cover,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          //user name
          title: Text(widget.user.name),
          //user Last message
          subtitle: Text(widget.user.about, maxLines: 1),
          //user Last message time
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
