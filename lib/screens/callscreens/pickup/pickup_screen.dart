import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_signup_screen/constants/strings.dart';
import 'package:login_signup_screen/methods/call_methods.dart';
import 'package:login_signup_screen/methods/local_db/repository/log_repository.dart';
import 'package:login_signup_screen/model/call.dart';
import 'package:login_signup_screen/model/log.dart';
import 'package:login_signup_screen/screens/callscreens/call_screen.dart';
import 'package:login_signup_screen/utils/permissions.dart';


class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    @required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  // final LogRepository logRepository = LogRepository(isHive: true);
  // final LogRepository logRepository = LogRepository(isHive: false);

  bool isCallMissed = true;

  addToLocalStorage({@required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    LogRepository.addLogs(log);
  }

  @override
  void dispose() {
    if (isCallMissed) {
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
    }
    super.dispose();
  }

  updateCallState() {
    FirebaseFirestore.instance
        .collection(CALL_COLLECTION)
        .doc(widget.call.callerId)
        .update({"callState": "Call Connected"});
    FirebaseFirestore.instance
        .collection(CALL_COLLECTION)
        .doc(widget.call.receiverId)
        .update({"callState": "Call Connected"});
  }

  @override
  Widget build(BuildContext context) {
    double WIDTH = MediaQuery.of(context).size.width;
    double HEIGTH = MediaQuery.of(context).size.height;

    return Scaffold(
      
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              top: HEIGTH * 0.15,
              child: Column(
                children: [
                  ClayContainer(
                    borderRadius: 90,
                    color: Colors.white70,
                    curveType: CurveType.convex,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(widget.call.callerPic),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    widget.call.callerName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              )),
          Positioned(
            bottom: HEIGTH * 0.16,
            left: 0,
            child: CustomPaint(
              size: Size(WIDTH, (HEIGTH * 0.45).toDouble()),
              //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
              painter: RPSCustomPainter(),
            ),
          ),
          Positioned(
            bottom: HEIGTH * 0.007,
            right: 0,
            child: CustomPaint(
              size: Size(WIDTH, (HEIGTH * 0.45).toDouble()),
              //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
              painter: RPSCustomPainter2(),
            ),
          ),
          Positioned(
              bottom: HEIGTH * 0.35,
              left: WIDTH * 0.1,
              child: IconButton(
                icon: Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () async {
                  isCallMissed = false;
                  addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                  await callMethods.endCall(call: widget.call);
                },
              )),
          Positioned(
              bottom: HEIGTH * 0.22,
              right: WIDTH * 0.1,
              child: IconButton(
                icon: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () async {
                  updateCallState();
                  if (widget.call.isCall == "video") {
                    await Permissions.cameraAndMicrophonePermissionsGranted()
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CallScreen(call: widget.call),
                            ),
                          )
                        : {};
                  } else {
                    // await Permissions.microphonePermissionsGranted()
                    //     ? Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) =>
                    //               VoiceCallScreen(call: widget.call),
                    //         ),
                    //       )
                    //     : {};
                  }
                },
              )),
        ],
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path_0 = Path();
    path_0.moveTo(0, size.height * 0.3000000);
    path_0.quadraticBezierTo(size.width * 0.3640625, size.height * 0.2835000,
        size.width * 0.3737500, size.height * 0.4980000);
    path_0.quadraticBezierTo(size.width * 0.3765625, size.height * 0.8005000, 0,
        size.height * 0.8000000);
    path_0.lineTo(0, size.height * 0.3000000);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RPSCustomPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path_0 = Path();
    path_0.moveTo(size.width, size.height * 0.2960000);
    path_0.quadraticBezierTo(size.width * 0.8896875, size.height * 0.1655000,
        size.width * 0.8112500, size.height * 0.2020000);
    path_0.cubicTo(
        size.width * 0.6543750,
        size.height * 0.2900000,
        size.width * 0.6068750,
        size.height * 0.5500000,
        size.width * 0.6225000,
        size.height * 0.6680000);
    path_0.quadraticBezierTo(size.width * 0.6496875, size.height * 0.8470000,
        size.width * 0.9375000, size.height * 0.7900000);
    path_0.quadraticBezierTo(size.width * 0.9906250, size.height * 0.7680000,
        size.width, size.height * 0.5980000);
    path_0.quadraticBezierTo(size.width, size.height * 0.5225000, size.width,
        size.height * 0.2960000);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
