// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/screens/view_profile_screen.dart';
import 'package:we_chat/widgets/message_card.dart';
import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({
    Key? key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];
  //for handling text messages
  final _textController = TextEditingController();
  //for showing or hiding the emoji board
  bool _showEmoji = false;
  //for checking whether the image is being uploaded or not
  bool _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          // or else simple close current screen on back button click
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
            backgroundColor: Color.fromARGB(255, 234, 248, 255),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return SizedBox();

                        // if some or all data is loaded then show It,
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data!.docs;
                          print(data.toString());
                          _list = data
                              .map((e) => Message.fromJson(e.data()))
                              .toList();
                          print(_list.length);
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(top: mq.height * .01),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index]);
                                });
                          } else {
                            return Center(
                              child: Text(
                                "Say hii 👋",
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                _isUploading
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )),
                      )
                    : SizedBox(),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                          bgColor: Color.fromARGB(255, 234, 248, 255),
                          columns: 8,
                          emojiSizeMax: 32 * 1.0),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //app bar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: ((context, snapshot) {
              final data = snapshot.data!.docs;
              final list =
                  data.map((e) => ChatUser.fromJson(e.data())).toList();

              return Row(
                children: [
                  //back button
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black54,
                      )),
                  //profile picture of user
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: mq.height * .05,
                      height: mq.height * .05,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  //for adding some space
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),
                      //for adding some space
                      SizedBox(
                        height: 2,
                      ),
                      //last seen time of user
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      )
                    ],
                  )
                ],
              );
            })));
  }

  //bottom chat input field

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * 0.025, vertical: mq.height * 0.01),
      child: Row(children: [
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                //emoji button
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 26,
                    )),
                //chat input textfield
                Expanded(
                    child: TextField(
                  onTap: () {
                    if (_showEmoji) {
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    }
                  },
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Type Something...',
                    hintStyle: TextStyle(color: Colors.blueAccent),
                    border: InputBorder.none,
                  ),
                )),
                //take image from gallery
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images) {
                        setState(() {
                          _isUploading = true;
                        });
                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 26,
                    )),
                //take image from camera
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    //pick image
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      print('Image Path: ${image.path}');
                      setState(() {
                        _isUploading = true;
                      });
                      await APIs.sendChatImage(widget.user, File(image.path));
                      setState(() {
                        _isUploading = false;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.blueAccent,
                    size: 26,
                  ),
                ),
                SizedBox(
                  width: mq.width * 0.02,
                )
              ],
            ),
          ),
        ),
        //send button
        MaterialButton(
          shape: CircleBorder(),
          color: Colors.green,
          minWidth: 0,
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              APIs.sendMessage(widget.user, _textController.text, Type.text);
              _textController.text = '';
            }
          },
          child: Icon(
            Icons.send,
            color: Colors.white,
            size: 28,
          ),
        )
      ]),
    );
  }
}
