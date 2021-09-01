import 'dart:async';
import 'dart:convert';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:login_signup_screen/configs/agora_configs.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/constants/strings.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';
import 'package:login_signup_screen/methods/call_methods.dart';
import 'package:login_signup_screen/model/call.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  CallScreen({
    @required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();

  StreamSubscription callStreamSubscription;

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  double screenWidth, screenHeight;
  final _isHours = true;
  RtcEngine _engine;
  UserController _userController = Get.find();

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    initializeAgora();
    sendNotification("Incoming Video Call", widget.call.callerName,
        widget.call.receiverFirebaseToken);
  }

  Future<void> initializeAgora() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // ignore: deprecated_member_use
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.call.channelId, null, 0);
    // if (APP_ID.isEmpty) {
    //   setState(() {
    //     _infoStrings.add(
    //       'APP_ID missing, please provide your APP_ID in settings.dart',
    //     );
    //     _infoStrings.add('Agora Engine is not starting');
    //   });
    //   return;
    // }

    // await _initAgoraRtcEngine();
    // _addAgoraEventHandlers();
    // await AgoraRtcEngine.enableWebSdkInteroperability(true);
    // await AgoraRtcEngine.setParameters(
    //     '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    // await AgoraRtcEngine.joinChannel(null, widget.call.channelId, null, 0);
  }

  var serverkey =
      "AAAA7z4C6UU:APA91bFmeFSVjJM3XQbTo7n7DV7pvg6K_7eWkFHLJNTDo-B31vddOhCYCiBvf4VulEHeI1x7R58kWtrDDNOglh05wqIEglgBPTMYyuCW3sqynBm2IqcrYswKQxXDO9XsDpUOQgXFkCUu";

  Future<void> sendNotification(
      String message, String sender, String receiver) async {
    print("Firebase Token: " + receiver);
    // FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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
    final Completer<RemoteMessage> completerr = Completer<RemoteMessage>();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      completerr.complete(message);
    });
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     completer.complete(message);
    //   },
    // );
  }

  addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      //userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userController.userData.value.uid)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data) {
          case null:
            // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;

          default:
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    // await AgoraRtcEngine.create(APP_ID);
    // await AgoraRtcEngine.enableVideo();
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      },
      connectionLost: () {
        setState(() {
          final info = 'onConnectionLost';
          _infoStrings.add(info);
        });
      },
      localUserRegistered: (
        int i,
        String s,
      ) {
        setState(() {
          final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
          _infoStrings.add(info);
        });
      },
      rejoinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'nRejoinChannelSuccess: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      userInfoUpdated: (i, userInfo) {
        setState(() {
          final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
          _infoStrings.add(info);
        });
      },
    ));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    // final List<AgoraRenderWidget> list = [
    //   AgoraRenderWidget(0, local: true, preview: true),
    // ];
    // _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    // return list;
    final List<StatefulWidget> list = [];
    if (_userController.userData.value.uid == widget.call.callerId) {
      list.add(RtcLocalView.SurfaceView());
    }

    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
          child: Column(
            children: <Widget>[_videoView(views[0])],
          ),
        );
      case 2:
        // return Container(
        //     child: Column(
        //   children: <Widget>[
        //     _expandedVideoRow([views[0]]),
        //     _expandedVideoRow([views[1]])
        //   ],
        // ));
        return new Container(
            width: double.infinity,
            height: double.infinity,
            child: new Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      _expandedVideoRow([views[1]]),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.white38,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.fromLTRB(15, 40, 10, 15),
                        width: 110,
                        height: 140,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _expandedVideoRow([views[0]]),
                          ],
                        )))
              ],
            ));

      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      case 5:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 5))
          ],
        ));
      case 6:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6))
          ],
        ));
      case 7:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
            _expandedVideoRow(views.sublist(6, 7)),
          ],
        ));
      default:
    }
    return Container();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    // AgoraRtcEngine.muteLocalAudioStream(muted);
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () async {
              await callMethods.endCall(
                call: widget.call,
              );
              Get.back();
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  updateCallState() {
    FirebaseFirestore.instance
        .collection(CALL_COLLECTION)
        .doc(widget.call.callerId)
        .update({"callState": "Call Ended"});
    FirebaseFirestore.instance
        .collection(CALL_COLLECTION)
        .doc(widget.call.receiverId)
        .update({"callState": "Call Ended"});
  }

  @override
  void dispose() async {
    // clear users
    _users.clear();
    updateCallState();

    // destroy sdk
    // AgoraRtcEngine.leaveChannel();
    // AgoraRtcEngine.destroy();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            //_panel(),

            _toolbar(),
          ],
        ),
      ),
    );
  }
}
