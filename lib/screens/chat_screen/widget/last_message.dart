import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/model/message.dart';
import 'package:timeago/timeago.dart' as tAgo;

class LastMessageContainer extends StatelessWidget {
  final stream;

  LastMessageContainer({
    @required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.docs;

          if (docList.isNotEmpty) {
            Message message = Message.fromMap(docList.last.data());

            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Row(
                children: [
                  message.idFrom ==
                          message.senderId //if its current user message
                      ? Icon(
                          Icons.done_all,
                          color:
                              message.isRead ? Colors.blue : Colors.grey[400],
                          size: 12,
                        )
                      //if its not my message
                      : message.isRead == false
                          ? Icon(Icons.done_all, color: Colors.green, size: 12)
                          : Icon(Icons.done_all, color: Colors.blue, size: 12),
                  Expanded(
                    child: Text(message.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 16)),
                  ),
                ],
              ),
            );
          }
          return Text("No Message",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                //color: Colors.white,
              ));
        }
        return Text("..",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              //color: Colors.white,
            ));
      },
    );
  }
}

class LastMessageTimeContainer extends StatelessWidget {
  final stream;

  LastMessageTimeContainer({
    @required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.docs;

          if (docList.isNotEmpty) {
            Message message = Message.fromMap(docList.last.data());

            return Expanded(
              child: Text(
                tAgo.format(message.timestamp.toDate()),
                maxLines: null,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  //color: appController.unReadColor.value,
                ),
              ),
            );
          }
          return Icon(FontAwesomeIcons.questionCircle);
        }
        return Text("..",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ));
      },
    );
  }
}
