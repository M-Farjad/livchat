import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livchat/screens/about_screen.dart';

import '../../constants/constants.dart';
import '../../main.dart';
import '../../models/chat_user.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 8, left: 10, right: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                //!for removing unnecessary corners in images
                borderRadius: BorderRadius.circular(mq.height * 0.15),
                child: CachedNetworkImage(
                  width: mq.height * .3,
                  height: mq.height * .3,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),
            Positioned(
              width: mq.width * .6, //need to specify bcz it stacks out
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            Positioned(
              right: 5,
              width: mq.width * .1,
              top: -5,
              child: MaterialButton(
                  color: Colors.white,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AboutScreen(user: user)));
                  },
                  shape: const CircleBorder(),
                  child: Icon(Icons.info_outlined,
                      color: kPrimaryColor, size: 30)),
            ),
          ],
        ),
      ),
      backgroundColor: kLightPrimaryColor.withOpacity(.95),
    );
  }
}
