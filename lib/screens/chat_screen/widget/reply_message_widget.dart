import 'package:flutter/material.dart';
import 'package:login_signup_screen/model/message.dart';

class ReplyMessageWidget extends StatelessWidget {
  final Message message;
  final VoidCallback onCancelReply;
  final String username;
  final bool topOfTextField;

  const ReplyMessageWidget({
    @required this.message,
    this.onCancelReply,
    this.username,
    this.topOfTextField,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          mainAxisSize: topOfTextField ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              color: Colors.blue[900],
              width: 4,
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.loose,
              child: buildReplyMessage(),
            ),
          ],
        ),
      );

  Widget buildReplyMessage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: topOfTextField ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  '$username',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (onCancelReply != null)
                GestureDetector(
                  child: Icon(Icons.close, size: 16),
                  onTap: onCancelReply,
                )
            ],
          ),
          const SizedBox(height: 8),
          Text(message.message, style: TextStyle(color: Colors.black54)),
        ],
      );
}
