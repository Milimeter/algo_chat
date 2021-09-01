import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:linkify_text/linkify_text.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/constants/strings.dart';
import 'package:login_signup_screen/methods/chat_methods.dart';
import 'package:login_signup_screen/model/message.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/chat_screen/widget/reply_message_widget.dart';
import 'package:login_signup_screen/utils/call_utils.dart';
import 'package:login_signup_screen/utils/permissions.dart';
import 'package:login_signup_screen/widgets/algo_app_bar/message_app_bar_action.dart';
import 'package:login_signup_screen/widgets/cached_image.dart';
import 'package:login_signup_screen/widgets/show_full_image.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'package:http/http.dart' as http;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatScreen extends StatefulWidget {
  final UserData receiver;

  ChatScreen({this.receiver});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatMethods _chatMethods = ChatMethods();

  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  ScrollController _listScrollController = ScrollController();
  UserData sender;
  String _currentUserId;
  bool isWriting = false;
  bool showEmojiPicker = false;
  bool ismessageRead = false;
  final _isScroll = true;

  @override
  void initState() {
    super.initState();
    userController.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        sender = UserData(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoURL,
        );
      });
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  sendMessage() async {
    var text = textFieldController.text;
    print(replyMessage);

    Message _message = Message(
      receiverId: widget.receiver.uid,
      senderId: sender.uid,
      message: text,
      timestamp: Timestamp.now(),
      type: 'text',
      isRead: false,
      idFrom: sender.uid,
      replyMessage: replyMessage,
    );

    setState(() {
      isWriting = false;
    });
    print("message sent");

    textFieldController.text = "";
    // await _chatMethods.isTyping(
    //     query: "",
    //     uid: _userController.userData.value.uid,
    //     ruid: widget.receiver.uid);
    _chatMethods.addMessageToDb(_message);
    sendNotification(_message.message.toString(), sender.name.toString(),
        widget.receiver.firebaseToken.toString());
    cancelReply();
  }

  var serverkey =
      "AAAAPWUeFmU:APA91bGagDG9DhZXoBpUnIKujmizlZgAZAz9K0aA2EOt_BOEqE9KeIe9Dvn4hs5ivBpbWnw5JB8TuzN3q2lmxFlyfLh_KT8Zrsvx9GTHw83S8m56suqS_WnOMKCutH2T2b7NjPzRh1e9";

  Future<void> sendNotification(
      String message, String sender, String receiver) async {
    print("Firebase Token: " + receiver);
    //FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'key=$serverkey',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        // "message": {
        "to": "$receiver",
        "collapse_key": "type_a",
        "priority": "high",
        "notification": {
          "title": "$sender",
          "body": "$message",
        },
        "data": {
          "title": "$sender",
          "body": "$message",
          "sound": "default",
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
        // }
      }),
    );
    // final Completer<Map<String, dynamic>> completer =
    //     Completer<Map<String, dynamic>>();

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     completer.complete(message);
    //   },
    // );
    final Completer<RemoteMessage> completerr = Completer<RemoteMessage>();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      completerr.complete(message);
    });
  }

  emojiContainer() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          setState(() {
            isWriting = true;
          });

          textFieldController.text = textFieldController.text + emoji.emoji;
          // Do something when emoji is tapped
        },
        onBackspacePressed: () {
          textFieldController
            ..text = textFieldController.text.characters.skipLast(1).toString()
            ..selection = TextSelection.fromPosition(
                TextPosition(offset: textFieldController.text.length));
          // Backspace-Button tapped logic
          // Remove this line to also remove the button in the UI
        },
        config: Config(
            columns: 7,
            emojiSizeMax: 32.0,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            initCategory: Category.RECENT,
            bgColor: Color(0xFFF2F2F2),
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            progressIndicatorColor: Colors.blue,
            showRecentsTab: true,
            recentsLimit: 28,
            noRecentsText: "No Recents",
            noRecentsStyle:
                const TextStyle(fontSize: 20, color: Colors.black26),
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            _buildAppBar(),
            Flexible(
              child: messageList(),
            ),
            _buildBottomChat(),
            showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ],
        ),
      ),
    );
  }

  _buildAppBar() async{
    return MessengerAppBarAction(
      isScroll: _isScroll,
      isBack: true,
      title: widget.receiver.name,
      imageUrl: widget.receiver.profilePhoto,
      subTitle: 'Active',
      actions: <Widget>[
        IconButton(

          icon: Icon(FontAwesomeIcons.phoneAlt,
          color: Colors.lightBlue,
          size: 20.0,),
          onPressed: () async =>
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: sender,
                      to: widget.receiver,
                      context: context,
                      callis: "video")
                  : {}, 
        ),
        Icon(
          FontAwesomeIcons.infoCircle,
          color: Colors.lightBlue,
          size: 20.0,
        ),
      ],
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.docChanges.isEmpty) {
          return Center(
            child: Text(
              "No messages yet, start chating with ${widget.receiver.name} now",
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            final lastMessage =
                Message.fromMap(snapshot.data.docs.first.data());
            _marksendMessagesAsRead(lastMessage);
            // mention the arrow syntax if you get the time
            return chatMessageItem(snapshot.data.docs[index]);
          },
        );
      },
    );
  }

  _buildBottomChat() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    final isReplying = replyMessage != null;
    Widget buildReply() => Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: ReplyMessageWidget(
            username: replyMessage.senderId == _currentUserId
                ? sender.username.replaceAll(RegExp(r'[0-9]'), '')
                : widget.receiver.username.replaceAll(RegExp(r'[0-9]'), ''),
            message: replyMessage,
            onCancelReply: cancelReply,
            topOfTextField: true,
          ),
        );

    return Column(
      children: [
        if (isReplying) buildReply(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.settings_input_svideo,
                    size: 25.0,
                    color: Colors.lightBlue,
                  ),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: Container(
                  child: TextField(
                    controller: textFieldController,
                    onTap: () => hideEmojiContainer(),
                    onChanged: (val) async {
                      (val.length > 0 && val.trim() != "")
                          ? setWritingTo(true)
                          : setWritingTo(false);
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        hintText: 'Enter Message',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        suffixIcon: Icon(
                          FontAwesomeIcons.solidSmileBeam,
                          size: 25.0,
                          color: Colors.lightBlue,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  onPressed: () => sendMessage(),
                  icon: Icon(
                    FontAwesomeIcons.paperPlane,
                    size: 25.0,
                    color: Colors.lightBlue,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _marksendMessagesAsRead(Message lastMessage) {
    if (lastMessage.idFrom == widget.receiver.uid) {
      FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver.uid)
          .where('idFrom', isEqualTo: widget.receiver.uid)
          .where('isRead', isEqualTo: false)
          .get()
          .then((documentSnapshot) {
        print(documentSnapshot.docs.length);
        if (documentSnapshot.docs.length > 0) {
          for (DocumentSnapshot doc in documentSnapshot.docs) {
            doc.reference.update({'isRead': true});
          }
        }
      });

      FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(widget.receiver.uid)
          .collection(_currentUserId)
          .where('idFrom', isEqualTo: widget.receiver.uid)
          .where('isRead', isEqualTo: false)
          .get()
          .then((documentSnapshot) {
        print(documentSnapshot.docs.length);
        if (documentSnapshot.docs.length > 0) {
          for (DocumentSnapshot doc in documentSnapshot.docs) {
            doc.reference.update({'isRead': true});
          }
        }
      });
    }
  }

  Message replyMessage;
  onSwipedMessage(message) {
    replyToMessage(message);
    textFieldFocus.requestFocus();
  }

  void replyToMessage(Message message) {
    setState(() {
      replyMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return SwipeTo(
      onRightSwipe: () => onSwipedMessage(_message),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10), //15
        child: Container(
          alignment: _message.senderId == _currentUserId
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: _message.senderId == _currentUserId
              ? FocusedMenuHolder(
                  menuWidth: MediaQuery.of(context).size.width * 0.50,
                  blurSize: 5.0,
                  menuItemExtent: 45,
                  menuBoxDecoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  duration: Duration(milliseconds: 100),
                  animateMenuItems: true,
                  blurBackgroundColor: Colors.black54,
                  bottomOffsetHeight: 100,
                  openWithTap: true,
                  menuItems: <FocusedMenuItem>[
                    FocusedMenuItem(
                        title: Text("Star"),
                        trailingIcon: Icon(Entypo.star),
                        onPressed: () {
                          Get.snackbar("Notice!", "Feature not available yet",
                              backgroundColor: Colors.white,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP);
                        }),
                    FocusedMenuItem(
                        title: Text("Reply"),
                        trailingIcon: Icon(Entypo.swap),
                        onPressed: () {}),
                    FocusedMenuItem(
                        title: Text("Copy"),
                        trailingIcon: Icon(Entypo.copy),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _message.message));
                          Get.snackbar("Copied!",
                              "The message has been copied to ClipBoard",
                              backgroundColor: Colors.white,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP);
                        }),
                    FocusedMenuItem(
                        title: Text("Delete",
                            style: TextStyle(color: Colors.redAccent)),
                        trailingIcon: Icon(Entypo.cup, color: Colors.redAccent),
                        onPressed: () async {
                          Get.snackbar("Notice!", "Feature not available yet",
                              backgroundColor: Colors.white,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP);
                        }),
                  ],
                  onPressed: () {},
                  child: senderLayout(_message))
              : FocusedMenuHolder(
                  menuWidth: MediaQuery.of(context).size.width * 0.50,
                  blurSize: 5.0,
                  menuItemExtent: 45,
                  menuBoxDecoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  duration: Duration(milliseconds: 100),
                  animateMenuItems: true,
                  blurBackgroundColor: Colors.black54,
                  bottomOffsetHeight: 100,
                  openWithTap: true,
                  menuItems: <FocusedMenuItem>[
                    FocusedMenuItem(
                        title: Text("Star"),
                        trailingIcon: Icon(Entypo.star),
                        onPressed: () {
                          Get.snackbar("Notice!", "Feature not available yet",
                              backgroundColor: Colors.white,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP);
                        }),
                    FocusedMenuItem(
                        title: Text("Reply"),
                        trailingIcon: Icon(Entypo.swap),
                        onPressed: () {}),
                    FocusedMenuItem(
                        title: Text("Copy"),
                        trailingIcon: Icon(Entypo.copy),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _message.message));
                          Get.snackbar("Copied!",
                              "The message has been copied to ClipBoard",
                              backgroundColor: Colors.white,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP);
                        }),
                    FocusedMenuItem(
                        title: Text("Delete",
                            style: TextStyle(color: Colors.redAccent)),
                        trailingIcon: Icon(Entypo.cup, color: Colors.redAccent),
                        onPressed: () async {
                          Get.snackbar("Notice!", "Feature not available yet",
                              backgroundColor: Colors.white,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP);
                        }),
                  ],
                  onPressed: () {},
                  child: receiverLayout(_message)),
        ),
      ),
    );
  }

  Widget senderLayout(Message smessage) {
    Radius messageRadius = Radius.circular(12);
    Color color = Colors.white;
    var isMe = smessage.senderId == _currentUserId;

    if (smessage.isRead) {
      // print("  message read");
      ismessageRead = true;
      //print(smessage.replyMessage);
    }

    return GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: smessage.message));
          Get.snackbar("Copied!", "The message has been copied to ClipBoard",
              backgroundColor: Colors.white,
              colorText: Colors.black,
              snackPosition: SnackPosition.TOP);
        },
        child: smessage.replyMessage == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65),
                    decoration: BoxDecoration(
                      color: smessage.type == 'sticker'
                          ? Colors.transparent
                          : Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: smessage.type == 'sticker'
                              ? Colors.transparent
                              : Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: messageRadius,
                        topRight: messageRadius,
                        bottomLeft: messageRadius,
                      ),
                    ),
                    // child: Padding(
                    //   padding: EdgeInsets.all(10),
                    //   child: getMessage(message),
                    // ),
                    child: Padding(
                      padding: smessage.type == "image" ||
                              smessage.type == "multipleimages"
                          ? EdgeInsets.all(2)
                          : EdgeInsets.all(10),
                      child: getUserMessage(smessage, color),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: Text(
                      tAgo.format(smessage.timestamp.toDate()),
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                  _currentUserId == smessage.idFrom
                      ? Icon(
                          Icons.done_all,
                          color: (smessage.isRead == true)
                              ? Colors.blue[900]
                              : Colors.grey[400],
                          size: 20.0,
                        )
                      : Container(),
                  // Icon(
                  //   Icons.done_all,
                  //   color:
                  //       ismessageRead ? Colors.blue[900] : Colors.grey[400],
                  //   size: 20.0,
                  // ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isMe && smessage.replyMessage == null
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.end,
                children: [
                  buildReplyMessage(smessage),
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65),
                    decoration: BoxDecoration(
                      color: smessage.type == 'sticker'
                          ? Colors.transparent
                          : Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: smessage.type == 'sticker'
                              ? Colors.transparent
                              : Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: messageRadius,
                        topRight: messageRadius,
                        bottomLeft: messageRadius,
                      ),
                    ),
                    // child: Padding(
                    //   padding: EdgeInsets.all(10),
                    //   child: getMessage(message),
                    // ),
                    child: Padding(
                      padding: smessage.type == "image" ||
                              smessage.type == "multipleimages"
                          ? EdgeInsets.all(2)
                          : EdgeInsets.all(10),
                      child: getUserMessage(smessage, color),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: Text(
                      tAgo.format(smessage.timestamp.toDate()),
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                  _currentUserId == smessage.idFrom
                      ? Icon(
                          Icons.done_all,
                          color: (smessage.isRead == true)
                              ? Colors.blue[900]
                              : Colors.grey[400],
                          size: 20.0,
                        )
                      : Container(),
                  // Icon(
                  //   Icons.done_all,
                  //   color:
                  //       ismessageRead ? Colors.blue[900] : Colors.grey[400],
                  //   size: 20.0,
                  // ),
                ],
              ));
  }

  getUserMessage(Message message, color) {
    if (message.type == "file") {
      return message.photoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        width: 130,
                        color: Colors.blueGrey,
                        height: 80,
                      ),
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'File',
                            style: TextStyle(
                                fontSize: 20, color: Color(0xff4fc3f7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    child: IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color: Colors.blue[900],
                      ),
                      onPressed: () {},
                      // onPressed: () => downloadFile(message.photoUrl),
                    ),
                  )
                ],
              ),
            )
          : Text(
              "Error, File Url was null. Try resending...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            );
    } else if (message.type == "video") {
      // ignore: unnecessary_statements
      // message.photoUrl != null ? buildVideoThumbnail(message.photoUrl) : {};
      // return message.photoUrl != null
      //     ? ClipRRect(
      //         borderRadius: BorderRadius.circular(8.0),
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //             Stack(
      //               alignment: AlignmentDirectional.center,
      //               children: [
      //                 Container(
      //                   width: 200,
      //                   color: Colors.transparent,
      //                   height: 200,
      //                 ),
      //                 Column(
      //                   children: <Widget>[
      //                     filePath != null
      //                         ? ClipRRect(
      //                             borderRadius: BorderRadius.circular(12.0),
      //                             child: Image(image: AssetImage(filePath)),
      //                           )
      //                         : CircularProgressIndicator(),
      //                     // Icon(
      //                     //   Icons.videocam,
      //                     //   color: Colors.white,
      //                     // ),
      //                     SizedBox(
      //                       height: 5,
      //                     ),
      //                     Text(
      //                       'Video',
      //                       style: TextStyle(
      //                           fontSize: 20, color: Colors.blue[900]),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //             Container(
      //               height: 40,
      //               child: IconButton(
      //                   icon: Icon(
      //                     Icons.play_arrow,
      //                     color: Colors.blue[900],
      //                   ),
      //                   onPressed: () =>
      //                       showVideoPlayer(context, message.photoUrl)),
      //             )
      //           ],
      //         ),
      //       )
      //     : Text(
      //         "Error, Video Url was null. Try resending...",
      //         style:
      //             TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      //       );
    } else if (message.type == "audio") {
      // return message.photoUrl != null
      //     ? Container(
      //         decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(13), color: Colors.grey),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //             // IconButton(
      //             //   icon: Icon(
      //             //     Icons.keyboard_voice,
      //             //     color: UniversalVariables.blackColor,
      //             //   ),
      //             //   onPressed: () => showAudioPlayer(context, message.photoUrl),
      //             // ),
      //             IconButton(
      //               icon: Icon(Icons.play_arrow, color: Colors.black),
      //               onPressed: () async {
      //                 if (_appController.isAudioPlaying.value == false) {
      //                   print(false);
      //                   _appController.isAudioPlaying.value = true;
      //                   await audioPlayer.play(message.photoUrl,
      //                       isLocal: false);
      //                 } else {
      //                   print(true);
      //                   audioPlayer.stop().then((value) {
      //                     _appController.isAudioPlaying.value = false;
      //                   });
      //                 }
      //               },
      //             ),
      //             IconButton(
      //                 icon: Icon(Icons.pause, color: Colors.black),
      //                 onPressed: () async {
      //                   await audioPlayer.pause();
      //                 })
      //           ],
      //         ),
      //       )
      //     : Container();
    } else if (message.type == MESSAGE_TYPE_IMAGE) {
      return message.photoUrl != null
          ? GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ShowFullImage(photoUrl: message.photoUrl))),
              child: CachedImage(
                // wrap with hero
                message.photoUrl,
                height: 250,
                width: 250,
                radius: 10,
              ),
            )
          : Text(
              "Error, Image Url was null. Try resending...",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            );
    } else if (message.type == 'sticker') {
      return Image.asset(
        'assets/Stickers/${message.message}.gif',
        height: 100.0,
      );
    } else if (message.type == 'text') {
      // return TextHighlight(
      //   text: message.message,
      //   words: _highlights,
      //   textStyle: TextStyle(color: color, fontSize: 16),
      // );
      return LinkifyText(
        message.message,
        textColor: color,
        fontSize: 16,
        linkColor: Colors.blue[700],
        isLinkNavigationEnable: true,
      );
      // style: TextStyle(color: color, fontSize: 16));
    } else if (message.type == 'multipleimages') {
      List<String> imagePaths =
          List<String>.from(json.decode(message.photoUrl));
      return GridView.builder(
        primary: false,
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imagePaths.length < 3 ? imagePaths.length : 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 1.5,
          mainAxisSpacing: 1.5,
        ),
        itemCount: imagePaths.length,
        itemBuilder: (ctx, index) {
          return ClipRRect(
            child: _buildImageWithLoading(imagePaths[index]),
            borderRadius: BorderRadius.only(
              topRight:
                  index == 0 ? Radius.circular(7.0) : Radius.circular(0.0),
              topLeft: index == 2
                  ? const Radius.circular(7.0)
                  : imagePaths.length == 2 && index == imagePaths.length - 1
                      ? const Radius.circular(7.0)
                      : const Radius.circular(0.0),
              bottomRight: index == imagePaths.length - 3 && index % 3 == 0
                  ? const Radius.circular(7.0)
                  : imagePaths.length - 1 == index && index % 3 == 0
                      ? const Radius.circular(7.0)
                      : imagePaths.length == 2 && index == 0
                          ? const Radius.circular(7.0)
                          : const Radius.circular(0.0),
              bottomLeft:
                  index == imagePaths.length - 1 && imagePaths.length % 3 == 0
                      ? const Radius.circular(7.0)
                      : imagePaths.length == 2 && index == imagePaths.length - 1
                          ? const Radius.circular(7.0)
                          : const Radius.circular(0.0),
            ),
          );
        },
      );
    }
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(12);
    if (message.isRead) {
      ismessageRead = true;
    }
    Color color = Colors.black54;

    return Row(
      //remove row and cachedImage if errored out
      children: [
        CachedImage(
          //pass to profile of the receiver
          widget.receiver.profilePhoto,
          radius: 40,
          isRound: true,
        ),
        SizedBox(width: 4),
        GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: message.message));
            Get.snackbar("Copied!", "The message has been copied to ClipBoard",
                backgroundColor: Colors.white,
                colorText: Colors.black,
                snackPosition: SnackPosition.TOP);
          },
          child: message.replyMessage == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // wrap this with probably a row widget for time display
                      margin: EdgeInsets.only(top: 12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: message.type == 'sticker'
                                ? Colors.transparent
                                : Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                        color: message.type == 'sticker'
                            ? Colors.transparent
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomRight: messageRadius,
                          topRight: messageRadius,
                          bottomLeft: messageRadius,
                        ),
                      ),
                      // child: Padding(
                      //   padding: EdgeInsets.all(10),
                      //   child: getMessage(message),
                      // ),
                      child: Padding(
                        padding: message.type == "image" ||
                                message.type == "multipleimages"
                            ? EdgeInsets.all(2)
                            : EdgeInsets.all(10),
                        child: getUserMessage(message, color),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Text(
                          tAgo.format(
                            message.timestamp.toDate(),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          )),
                    )
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: message.replyMessage == null
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.start,
                  children: [
                    buildReplyMessage(message),
                    Container(
                      // wrap this with probably a row widget for time display
                      margin: EdgeInsets.only(top: 12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: message.type == 'sticker'
                                ? Colors.transparent
                                : Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                        color: message.type == 'sticker'
                            ? Colors.transparent
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomRight: messageRadius,
                          topRight: messageRadius,
                          bottomLeft: messageRadius,
                        ),
                      ),
                      // child: Padding(
                      //   padding: EdgeInsets.all(10),
                      //   child: getMessage(message),
                      // ),
                      child: Padding(
                        padding: message.type == "image" ||
                                message.type == "multipleimages"
                            ? EdgeInsets.all(2)
                            : EdgeInsets.all(10),
                        child: getUserMessage(message, color),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Text(
                          tAgo.format(
                            message.timestamp.toDate(),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          )),
                    )
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildImageWithLoading(String imageUrl) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowFullImage(photoUrl: imageUrl))),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        progressIndicatorBuilder: (_, child, loadingProgress) {
          if (loadingProgress.totalSize == null) return _buildEmptyContainer();

          return Stack(
            children: <Widget>[
              _buildEmptyContainer(),
              Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor:
                      loadingProgress.downloaded / loadingProgress.totalSize,
                  child: Container(
                    color: Colors.black12,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyContainer() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
    );
  }

  Widget buildReplyMessage(Message message) {
    final replyMessage = message.replyMessage;
    final isReplying = replyMessage != null;

    if (!isReplying) {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        child: ReplyMessageWidget(
          message: replyMessage,
          username: replyMessage.senderId == _currentUserId
              ? sender.username
              : widget.receiver.username,
          topOfTextField: false,
        ),
      );
    }
  }
}
