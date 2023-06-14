import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/chat_screen.dart';
import 'package:we_chat/widgets/dialogs/profile_dialog.dart';

import '../api/apis.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info (if null --> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 1,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data!.docs;
                final list =
                    data.map((e) => Message.fromJson(e.data())).toList();
                if (list.isNotEmpty) {
                  _message = list[0];
                }

                return ListTile(
                    leading: InkWell(
                      onTap: (){
                        showDialog(context: context, builder: (_) => ProfileDialog(chatUser: widget.user,));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.03),
                        child: CachedNetworkImage(
                          width: mq.height * .055,
                          height: mq.height * .055,
                          imageUrl: widget.user.image,
                          // placeholder: (context, url) => Icon(CupertinoIcons.person),
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                    ),
                    //user name
                    title: Text(widget.user.name),
                    subtitle: _message!.type == Type.text
                        ? Text(
                            _message != null
                                ? _message!.msg
                                : widget.user.about,
                            maxLines: 1,
                          )
                        : Text(
                            'Image 📷',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                    // last message time
                    trailing: _message == null
                        ? null //show nothing when no message is sent
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user!.uid
                            ?
                            //show for unread message
                            Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            :
                            //message sent time
                            Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: TextStyle(color: Colors.black54),
                              ));
              })),
    );
  }
}
