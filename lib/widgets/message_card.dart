// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/helper/my_date_util.dart';

import 'package:we_chat/models/message.dart';

import '../api/apis.dart';
import '../main.dart';

//for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({
    Key? key,
    required this.message,
  });
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user!.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  // sender or another user message
  Widget _blueMessage() {
    print('Inside BlueMessage');
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      print('message read updated');
      print(widget.message.msg);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue),
                color: Colors.blue[100],
                //making borders curved
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.image),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13, color: Colors.black54)),
        )
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // for adding some space
            SizedBox(width: mq.width * .04),
            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            //for adding some space
            SizedBox(width: 2),
            Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: TextStyle(color: Colors.black54, fontSize: 13)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightGreen),
                color: Colors.green[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: widget.message.type == Type.text
                ?
                //Show text
                Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //Show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.image),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
