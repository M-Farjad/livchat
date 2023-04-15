import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:livchat/api/apis.dart';
import 'package:livchat/main.dart';

import '../constants/constants.dart';
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
    return APIs.user.uid == widget.message.fromID
        ? _greenMessage()
        : _blueMessage();
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
            padding: EdgeInsets.all(mq.width * .04),
            decoration: BoxDecoration(
                border: Border.all(color: kSecondaryMessageColor, width: 2),
                color: kSecondaryMessageColorLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: mq.height * .01),
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
            padding: EdgeInsets.all(mq.width * .04),
            decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 2),
                color: kLightPrimaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
