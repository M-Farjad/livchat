import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livchat/api/apis.dart';
import 'package:livchat/constants/constants.dart';
import 'package:livchat/helper/my_date_util.dart';
import 'package:livchat/models/message_model.dart';

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
  //last message info -> (if null -> no message)
  MessageModel? _message;
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => MessageModel.fromJson(e.data())).toList() ??
                      [];
              if (list.isNotEmpty) {
                _message = list[0];
              }
              return ListTile(
                  //user image
                  leading: ClipRRect(
                    //!for removing unnecessary corners in images
                    borderRadius: BorderRadius.circular(mq.height * 0.3),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      fit: BoxFit.cover,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  //user name
                  title: Text(widget.user.name),
                  //user Last message
                  subtitle: Text(
                      _message != null ? _message!.msg : widget.user.about,
                      maxLines: 1),
                  //user Last message time
                  trailing: _message == null
                      ? null //show nothhing when no message is sent
                      : _message!.read.isEmpty &&
                              _message!.fromID != APIs.user.uid
                          ? //show for unread messages
                          Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: kPrimaryColor),
                            )
                          : //message sent time
                          Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: const TextStyle(color: Colors.black54)));
            },
          )),
    );
  }
}
