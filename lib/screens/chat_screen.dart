import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  // _showEmoji for showing the value of showing or hiding emoji
  //_isUploading for checking if image is uploading or not
  bool _showEmoji = false, _isUploading = false;

  //for handling text message changes
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false, flexibleSpace: _appBar()),
          backgroundColor: Color.fromARGB(255, 227, 255, 228),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //!if data is loading
                        // // if data is small then it will be loaded immediately
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const SizedBox();
                        //!if data is loaded
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => MessageModel.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.symmetric(
                                  vertical: mq.height * 0.01),
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
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined, size: 26),
                    color: Theme.of(context).primaryColor,
                  ),
                  //Expanded to specify TextField width
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
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
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      //picking Multiple pics
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images) {
                        log("Image Path: ${i.path}");
                        setState(() => _isUploading = true);
                        //uploading & sending images one by one
                        await APIs.sendChatImages(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(Icons.image_outlined, size: 26),
                    color: Theme.of(context).primaryColor,
                  ),
                  //Camera Button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 70);
                      if (image != null) {
                        log("Image Path: ${image.path} -- MimeType: ${image.mimeType}");
                        setState(() => _isUploading = true);
                        await APIs.sendChatImages(
                            widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
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
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
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
