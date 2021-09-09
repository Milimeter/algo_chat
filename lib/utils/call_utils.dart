

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:login_signup_screen/constants/strings.dart';
import 'package:login_signup_screen/methods/call_methods.dart';
import 'package:login_signup_screen/methods/local_db/repository/log_repository.dart';
import 'package:login_signup_screen/model/call.dart';
import 'package:login_signup_screen/model/log.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/callscreens/call_screen.dart';


class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserData from, UserData to, context, String callis}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
      isCall: callis,
      receiverFirebaseToken: to.firebaseToken,
      callState: "Calling..."

      
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),

    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // enter log
      LogRepository.addLogs(log);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call),
        ),
      );
    }
  }

  static dialVoice({UserData from, UserData to, context, String callis}) async {  
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
      isCall: callis,
      receiverFirebaseToken: to.firebaseToken,
      callState: "Calling..."
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeVoiceCall(call: call);  

    call.hasDialled = true;

    if (callMade) {
      // enter log
      LogRepository.addLogs(log);
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => VoiceCallScreen(call: call),
      //     ));
    }
  }
  
}
