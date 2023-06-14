// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/screens/view_profile_screen.dart';

import '../../main.dart';
import '../../models/chat_user.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser chatUser;
  const ProfileDialog({
    Key? key,
    required this.chatUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            //user profile picture
            Positioned(
              top: mq.height * .066,
              left: mq.width * 0.09,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  width: mq.height * 0.26,
                  height: mq.height * 0.26,
                  fit: BoxFit.cover,
                  imageUrl: chatUser.image,
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),

            //user name
            Positioned(
              left: mq.width * .04,
              top: mq.height * .02,
              width: mq.width * .55,
              child: Text(
                chatUser.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(user: chatUser)));
                  },
                  minWidth: 0,
                  padding: EdgeInsets.zero,
                  shape: CircleBorder(),
                  child: Icon(Icons.info_outline_rounded)),
            )
          ],
        ),
      ),
    );
  }
}
