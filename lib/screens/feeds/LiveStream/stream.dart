import 'dart:async';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/configs/agora_configs.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';
import 'package:login_signup_screen/screens/feeds/LiveStream/messaging.dart';
import 'package:login_signup_screen/screens/feeds/LiveStream/models/message.dart';
import 'package:login_signup_screen/utils/HearAnim.dart';


import 'package:wakelock/wakelock.dart';
import 'dart:math' as math;

class BroadcastPage extends StatefulWidget {
  final String channelName;
  final String userName;
  final bool isBroadcaster;

  const BroadcastPage(
      {Key key, this.channelName, this.userName, this.isBroadcaster})
      : super(key: key);

  @override
  _BroadcastPageState createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
  UserController _userController = Get.find();
  final _users = <int>[];
  final _infoStrings = <String>[];
  final _infoStringss = <Message>[];
  RtcEngine _engine;
  bool muted = false;

  //for chat
  AgoraRtmClient _client;
  AgoraRtmChannel _channel;
  bool _isLogin = false;
  bool _isInChannel = false;
  final _channelMessageController = TextEditingController();
  bool heart = false;
  //Love animation
  final _random = math.Random();
  Timer _timer;
  double height = 0.0;
  int _numConfetti = 5;
  int guestID = -1;
  bool waiting = false;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk and leave channel
    _engine.destroy();

    _seconds.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    _createClient();
  }

  Future<void> initialize() async {
    print('Client Role: ${widget.isBroadcaster}');
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
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      await _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      await _engine.setClientRole(ClientRole.Audience);
    }
  }

  //for stream messaging
  void _createClient() async {
    print("===================================");
    _client = await AgoraRtmClient.createInstance(APP_ID);
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _logPeer(message.text);
    };
    _client.onConnectionStateChanged = (int state, int reason) {
      print('Connection state changed: ' +
          state.toString() +
          ', reason: ' +
          reason.toString());
      if (state == 5) {
        _client.logout();
        print('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };

    _toggleLogin();
    _toggleJoinChannel();
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) {
      print(
          "Member joined: " + member.userId + ', channel: ' + member.channelId);
      _logs(info: 'Member joined: ', user: member.userId, type: 'join');
    };
    channel.onMemberLeft = (AgoraRtmMember member) {
      print("Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      _logs(user: member.userId, info: message.text, type: 'message');
      // _logPeer(message.text);
    };
    return channel;
  }

  void _toggleLogin() async {
    if (!_isLogin) {
      try {
        await _client.login(null, widget.userName);
        print('Login success: ' + widget.userName);
        setState(() {
          _isLogin = true;
        });
      } catch (errorCode) {
        print('Login error: ' + errorCode.toString());
      }
    }
  }

  void _toggleJoinChannel() async {
    try {
      _channel = await _createChannel(widget.channelName);
      await _channel.join();
      print('Join channel success.');

      setState(() {
        _isInChannel = true;
      });
    } catch (errorCode) {
      print('Join channel error: ' + errorCode.toString());
    }
  }

  void _logPeer(String info) {
    info = '%' + info;
    print(info);
    setState(() {
      _infoStrings.insert(0, info);
    });
  }

  void _log(String info) {
    print(info);
    setState(() {
      _infoStrings.insert(0, info);
    });
  }

  void _logs({String info, String type, String user}) {
    if (type == 'message' && info.contains('m1x2y3z4p5t6l7k8')) {
      popUp();
    } else if (type == 'message' && info.contains('E1m2I3l4i5E6')) {
      stopFunction();
    } else {
      Message m;
      // var image =
      //     "https://cdn.pixabay.com/photo/2021/06/21/07/11/woman-6352831_960_720.png";
      var image = _userController.userData.value.profilePhoto;
      if (info.contains('d1a2v3i4s5h6')) {
        var mess = info.split(' ');
        if (mess[1] == widget.userName) {
          /*m = new Message(
              message: 'working', type: type, user: user, image: image);*/
          setState(() {
            //_infoStrings.insert(0, m);
            // requested = true;
          });
        }
      } else {
        m = new Message(message: info, type: type, user: user, image: image);
        setState(() {
          _infoStringss.insert(0, m);
        });
      }
    }
  }

  void popUp() async {
    setState(() {
      heart = true;
    });
    //125
    _timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) {
      setState(() {
        height += _random.nextInt(20);
      });
    });

    Timer(
        Duration(seconds: 5),
        () => {
              _timer.cancel(),
              setState(() {
                heart = false;
              })
            });
  }

  Widget heartPop() {
    final size = MediaQuery.of(context).size;
    final confetti = <Widget>[];
    for (var i = 0; i < _numConfetti; i++) {
      final height = _random.nextInt(size.height.floor());
      final width = 20;
      confetti.add(HeartAnim(
        height % 200.0,
        width.toDouble(),
        0.5,
      ));
    }

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 400,
            width: 200,
            child: Stack(
              children: confetti,
            ),
          ),
        ),
      ),
    );
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
      await Wakelock.enable();
      // This is used for Keeping the device awake. Its now enabled
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        completed = true;
        Future.delayed(const Duration(milliseconds: 1500), () async {
          await Wakelock.disable();
          // Navigator.pop(context);
        });
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  Timer _seconds;
  int _start = 5;

  void startTimer() {
    if (_start == 0) {
      Navigator.pop(context);
    }
    const oneSec = const Duration(seconds: 1);
    _seconds = new Timer.periodic(
      oneSec,
      (Timer seconds) {
        if (_start == 0) {
          setState(() {
            seconds.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Widget _ending() {
    startTimer();
    return Container(
      color: Colors.black.withOpacity(.7),
      child: Center(
          child: Container(
        width: double.infinity,
        color: Colors.grey[700],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Text(
                'The Live Stream has ended',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              Text(
                "You can exit the screen in $_start",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _liveText() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Colors.indigo, Colors.blue],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 10),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.6),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  height: 28,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.eye,
                          color: Colors.white,
                          size: 13,
                        ),
                      ],
                    ),
                  )),
            ),
            widget.isBroadcaster
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                    child: MaterialButton(
                      minWidth: 0,
                      onPressed: _onSwitchCamera,
                      child: Icon(
                        Icons.switch_camera,
                        color: Colors.blue[400],
                        size: 20.0,
                      ),
                      shape: CircleBorder(),
                      elevation: 2.0,
                      color: Colors.white,
                      padding: const EdgeInsets.all(12.0),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return widget.isBroadcaster
        ? Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: _onToggleMute,
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted ? Colors.white : Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
                RawMaterialButton(
                  onPressed: () => _onCallEnd(context),
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
                ),
                RawMaterialButton(
                  onPressed: _goToChatPage,
                  child: Icon(
                    Icons.message_rounded,
                    color: Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              ],
            ),
          )
        : Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 48),
            child: RawMaterialButton(
              onPressed: _goToChatPage,
              child: Icon(
                Icons.message_rounded,
                color: Colors.blueAccent,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        body: Center(
          child: (completed == true && widget.isBroadcaster == false)
              ? _ending()
              : Stack(
                  children: <Widget>[
                    _viewRows(),
                    //_toolbar(),

                    if (tryingToEnd == false && widget.isBroadcaster == true)
                      _endCall(),
                    if (tryingToEnd == false) _liveText(),

                    if (tryingToEnd == false) _bottomBar(), // send message
                    if (tryingToEnd == false) messageList(),
                    if (heart == true && completed == false) heartPop(),

                    if (tryingToEnd == true) endLive(), // view message
                  ],
                ),
        ),
      ),
    );
  }

  //   /// Info panel to show logs
  Widget messageList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStringss.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStringss.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: (_infoStringss[index].type == 'join')
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            // CachedNetworkImage(
                            //   imageUrl: _infoStrings[index].image,
                            //   imageBuilder: (context, imageProvider) => Container(
                            //     width: 32.0,
                            //     height: 32.0,
                            //     decoration: BoxDecoration(
                            //       shape: BoxShape.circle,
                            //       image: DecorationImage(
                            //           image: imageProvider, fit: BoxFit.cover),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                '${_infoStringss[index].user} joined',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : (_infoStringss[index].type == 'message')
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CachedNetworkImage(
                                  imageUrl: _infoStringss[index].image,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 32.0,
                                    height: 32.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        _infoStringss[index].user,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        _infoStringss[index].message,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        : null,
              );
            },
          ),
        ),
      ),
    );
  }

  // bool waiting = false;
  int userNo = 0;
  var tryingToEnd = false;
  bool personBool = false;
  bool anyPerson = false;
  bool accepted = false;
  bool completed = false;

  Future<bool> _willPopCallback() async {
    if (personBool == true) {
      setState(() {
        personBool = false;
      });
    } else {
      setState(() {
        tryingToEnd = !tryingToEnd;
      });
    }
    return false; // return true if the route to be popped
  }

  void stopFunction() {
    setState(() {
      accepted = false;
    });
  }

  Widget endLive() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                'Are you sure you want to end your live video?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 4.0, top: 8.0, bottom: 8.0),
                    // ignore: deprecated_member_use
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'End Video',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      elevation: 2.0,
                      color: Colors.blue,
                      onPressed: () async {
                        await Wakelock.disable();
                        //_leaveChannel();
                        _engine.leaveChannel();
                        _engine.destroy();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 4.0, right: 8.0, top: 8.0, bottom: 8.0),
                    // ignore: deprecated_member_use
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      elevation: 2.0,
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          tryingToEnd = false;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _endCall() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: GestureDetector(
              onTap: () {
                if (personBool == true) {
                  setState(() {
                    personBool = false;
                  });
                }
                setState(() {
                  if (waiting == true) {
                    waiting = false;
                  }
                  tryingToEnd = true;
                });
              },
              child: Text(
                'END',
                style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Info panel to show logs

  Widget _bottomBar() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomRight,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
              child: new TextField(
                  cursorColor: Colors.blue,
                  textInputAction: TextInputAction.send,
                  //onSubmitted: _sendMessage,
                  style: TextStyle(color: Colors.white),
                  controller: _channelMessageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Comment',
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide(color: Colors.white)),
                  )),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: _toggleSendChannelMessage,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                color: Colors.blue[400],
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            widget.isBroadcaster
                ? RawMaterialButton(
                    onPressed: _onToggleMute,
                    child: Icon(
                      muted ? Icons.mic_off : Icons.mic,
                      color: muted ? Colors.white : Colors.blueAccent,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: muted ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  )
                : SizedBox(),
            // RawMaterialButton(
            //   onPressed: _goToChatPage,
            //   child: Icon(
            //     Icons.message_rounded,
            //     color: Colors.blue[400],
            //     size: 20.0,
            //   ),
            //   shape: CircleBorder(),
            //   elevation: 2.0,
            //   fillColor: Colors.white,
            //   padding: const EdgeInsets.all(12.0),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: () async {
                  popUp();
                  await _channel.sendMessage(
                      AgoraRtmMessage.fromText('m1x2y3z4p5t6l7k8'));
                },
                child: Icon(
                  FontAwesomeIcons.solidHeart,
                  color: Colors.white,
                  size: 30.0,
                ),
                padding: const EdgeInsets.all(12.0),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _toggleSendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      print('Please input text to send.');
      return;
    }
    try {
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      _logs(user: userController.userData.value.username, info: text, type: 'message');
      // _log(text);
      _channelMessageController.clear();
    } catch (errorCode) {
      print('Send channel message error: ' + errorCode.toString());
    }
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.isBroadcaster) {
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
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
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
      default:
    }
    return Container();
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _goToChatPage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => RealTimeMessaging(
        channelName: widget.channelName,
        userName: widget.userName,
        isBroadcaster: widget.isBroadcaster,
      ),
    ));
  }
}
