import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/services.dart';
import 'package:livchat/api/apis.dart';
import 'package:livchat/main.dart';

import '../constants/constants.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import '../models/message_model.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final MessageModel message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isME = APIs.user.uid == widget.message.fromID;
    return InkWell(
      onLongPress: () {
        _showBottonSheet(isME);
      },
      child: isME ? _greenMessage() : _blueMessage(),
    );
  }

  //!Sender or Another user message
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      // log('read Message Updated');
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: mq.height * .01, horizontal: mq.width * .04),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * 0.04),
            decoration: BoxDecoration(
                border: Border.all(color: kSecondaryMessageColor, width: 2),
                color: kSecondaryMessageColorLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    //!for removing unnecessary corners in images
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      // height: mq.height * .05,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(bottom: mq.height * .01, right: mq.width * 0.03),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: kSecondaryMessageColor),
          ),
        )
      ],
    );
  }

  //!Our or user message
  Widget _greenMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            if (widget.message.read.isNotEmpty)
              Icon(Icons.done_all_rounded,
                  color: kSecondaryMessageColor, size: 20),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: mq.height * .01, horizontal: mq.width * .04),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * 0.04),
            decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 2),
                color: kLightPrimaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    //!for removing unnecessary corners in images
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      // height: mq.height * .05,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //!Bottom Sheet for modifying message details
  void _showBottonSheet(bool isMe) {
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
          shrinkWrap: true,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .4, vertical: mq.height * .015),
              height: 4,
            ),
            widget.message.type == Type.text
                ? _OptionItem(
                    icon: Icon(Icons.copy_rounded,
                        color: kPrimaryColor, size: 26),
                    name: "Copy",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        //for hiding bottom sheet
                        Navigator.pop(context);
                        Dialogs.showSnackbar(context, "Text Copied");
                      });
                    },
                  )
                : _OptionItem(
                    icon: Icon(Icons.download_for_offline_outlined,
                        color: kPrimaryColor, size: 26),
                    name: "Download",
                    onTap: () async {
                      log("Image Url: ${widget.message.msg}");
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'Livchat')
                            .then((success) {
                          //for hiding bottom sheet
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackbar(context, "Image Saved");
                          }
                        });
                      } catch (e) {
                        log('Error Saving Image: $e');
                      }
                    },
                  ),
            if (isMe)
              Divider(
                  endIndent: mq.height * .04,
                  indent: mq.height * .04,
                  color: Colors.black54),
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                icon: Icon(Icons.edit_note_rounded,
                    color: kSecondaryMessageColor, size: 26),
                name: "Edit",
                onTap: () {
                  //For hiding bottom sheet
                  Navigator.pop(context);
                  _showMessageUpdateDialog();
                },
              ),
            if (isMe)
              _OptionItem(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 26),
                name: "Delete",
                onTap: () async {
                  await APIs.deleteMessage(widget.message).then((value) {
                    //for hiding bottom sheet
                    Navigator.pop(context);
                    Dialogs.showSnackbar(context, "Message Deleted");
                  });
                },
              ),
            Divider(
                endIndent: mq.height * .04,
                indent: mq.height * .04,
                color: Colors.black54),
            _OptionItem(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.grey,
              ),
              name: "Sent at: ${MyDateUtil.getMessageTime(
                context: context,
                time: widget.message.sent,
              )}",
              onTap: () {},
            ),
            _OptionItem(
              icon: const Icon(Icons.remove_red_eye_outlined),
              name: widget.message.read.isEmpty
                  ? "Read: Not Read Yet"
                  : "Read at: ${MyDateUtil.getMessageTime(
                      context: context,
                      time: widget.message.read,
                    )}",
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void _showMessageUpdateDialog() {
    String updatedMessage = widget.message.msg;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.message, size: 28, color: kPrimaryColor),
            const Text('  Edit Message'),
          ],
        ),
        content: TextFormField(
          initialValue: updatedMessage,
          onChanged: (value) => updatedMessage = value,
          decoration: InputDecoration(
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
            onPressed: () {
              APIs.updateMessage(widget.message, updatedMessage);
              Navigator.pop(context);
            },
            child: Text(
              'Update',
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

class _OptionItem extends StatelessWidget {
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: mq.width * .08, vertical: mq.height * .015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              "    $name",
              style: const TextStyle(letterSpacing: 1, fontSize: 16),
            )),
          ],
        ),
      ),
    );
  }
}
