import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/constants/asset_path.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';
import 'package:login_signup_screen/screens/feeds/LiveStream/stream.dart';
import 'package:login_signup_screen/utils/permissions.dart';
import 'package:login_signup_screen/utils/text_styles.dart';
import 'package:login_signup_screen/widgets/cached_image.dart';

class ChooseCall extends StatelessWidget {
  final UserController _userController = Get.find();

  Widget startBroadcast(context) => GestureDetector(
        onTap: () => showDialog(
            context: context,
            builder: (context) {
              return CreateBroadCast();
            }),
        child: Container(
          height: 250,
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(4, 8),
                  blurRadius: 2,
                  spreadRadius: 1,
                  color: Colors.grey[200],
                )
              ]
              // gradient: LinearGradient(
              //   begin: Alignment.topRight,
              //   end: Alignment.bottomLeft,
              //   colors: [
              //     Color(0xff3AC2F8),
              //     Color(0xff75D4FA),
              //   ],
              // ),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Live Broadcast",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Create Live Video Streaming",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    "Start Streaming",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  Widget rowContainer({IconData icon, String text, Function onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150,
          width: 100,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                offset: Offset(4, 8),
                blurRadius: 2,
                spreadRadius: 1,
                color: Colors.grey[200],
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(height: 15),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
  @override
  Widget build(BuildContext context) {
    var WIDTH = MediaQuery.of(context).size.width;
    var HEIGHT = MediaQuery.of(context).size.height;
    var size = MediaQuery.of(context).size;
    return PickupLayout(
      scaffold: Scaffold(
        body: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: CustomPaint(
                size: Size(
                    WIDTH,
                    (HEIGHT * 0.5)
                        .toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                painter: RPSCustomPainter(),
              ),
            ),
            Positioned(
              bottom: 0,
              child: CustomPaint(
                size: Size(
                    WIDTH,
                    (HEIGHT * 0.375)
                        .toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                painter: RPSCustomPainter(),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hi, ${_userController.userData.value.username}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CachedImage(
                          //pass to profile of the receiver
                          _userController.userData.value.profilePhoto,
                          radius: 50,
                          isRound: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    startBroadcast(context),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                            width: size.width * 0.40,
                            child: rowContainer(
                              icon: Entypo.video_camera,
                              text: "Join Stream",
                              onTap: () => showDialog(
                                  context: context,
                                  builder: (context) {
                                    return JoinBroadCast();
                                  }),
                            )),
                        SizedBox(
                            width: size.width * 0.40,
                            child: rowContainer(
                                icon: Entypo.calendar,
                                text: "Schedule Live Stream",
                                onTap: () => Get.snackbar(
                                      "Notice!",
                                      "Functionality coming soon",
                                    ))),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = Colors.blue[900]
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path_0 = Path();
    path_0.moveTo(0, size.height * 0.1250000);
    path_0.quadraticBezierTo(size.width * 0.3087500, size.height * 0.4993750,
        size.width * 0.6812500, size.height * 0.5575000);
    path_0.quadraticBezierTo(size.width * 0.8515625, size.height * 0.5725000,
        size.width, size.height * 0.3950000);
    path_0.quadraticBezierTo(size.width * 1.0003125, size.height * 0.5431250,
        size.width, size.height);
    path_0.lineTo(size.width * 0.0012500, size.height * 0.9950000);
    path_0.quadraticBezierTo(size.width * 0.0009375, size.height * 0.7775000, 0,
        size.height * 0.1250000);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path_0 = Path();
    path_0.moveTo(0, size.height * 0.1600000);
    path_0.quadraticBezierTo(size.width * 0.2493750, size.height * 0.6966667,
        size.width * 0.3675000, size.height * 0.5600000);
    path_0.quadraticBezierTo(size.width * 0.5800000, size.height * 0.1641667,
        size.width * 0.8125000, size.height * 0.1700000);
    path_0.quadraticBezierTo(size.width * 0.9381250, size.height * 0.2025000,
        size.width * 0.9987500, size.height * 0.4333333);
    path_0.lineTo(size.width, size.height * 0.9966667);
    path_0.lineTo(size.width * 0.0012500, size.height * 0.9966667);
    path_0.quadraticBezierTo(size.width * 0.0009375, size.height * 0.7875000, 0,
        size.height * 0.1600000);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CreateBroadCast extends StatelessWidget {
  TextEditingController channelName = TextEditingController();
  String check = '';
  bool _isBroadcaster = true;
  UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Create Live Stream",
          style: TextStyle(color: Colors.black)),
      content: Column(
        // shrinkWrap: true,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            stream,
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: channelName,
            decoration: InputDecoration(
                hintText: "Create Access Key",
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black, width: 2)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue, width: 2))),
            style: regularTxtStyle.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          // ignore: deprecated_member_use
          FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            color: Colors.blue,
            onPressed: () async {
              if (channelName.text.isNotEmpty) {
                bool isPermissionGranted =
                    await Permissions.cameraAndMicrophonePermissionsGranted();
                if (isPermissionGranted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BroadcastPage(
                        userName: _userController.userData.value.username,
                        channelName: channelName.text.trim(),
                        isBroadcaster: _isBroadcaster,
                      ),
                    ),
                  );
                } else {
                  Get.snackbar("Failed", "Enter Broadcast key.",
                      backgroundColor: Colors.white,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM);
                }
              } else {
                Get.snackbar(
                    "Failed", "Microphone Permission Required for Video Call.",
                    backgroundColor: Colors.white,
                    colorText:Colors.blue,
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward, color: Colors.white),
                const SizedBox(
                  width: 20,
                ),
                Text("Start BroadCast",
                    style: regularTxtStyle.copyWith(
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JoinBroadCast extends StatelessWidget {
  TextEditingController channelName = TextEditingController();
  String check = '';
  bool _isBroadcaster = false;
  UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Join Live Stream",
          style: TextStyle(color: Colors.black)),
      content: Column(
        // shrinkWrap: true,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            join,
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: channelName,
            decoration: InputDecoration(
                hintText: "Enter Broadcast Key",
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black, width: 2)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue, width: 2))),
            style: regularTxtStyle.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          // ignore: deprecated_member_use
          FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            color: Colors.blue,
            onPressed: () async {
              if (channelName.text.isNotEmpty) {
                bool isPermissionGranted =
                    await Permissions.cameraAndMicrophonePermissionsGranted();
                if (isPermissionGranted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BroadcastPage(
                        userName: _userController.userData.value.username,
                        channelName: channelName.text.trim(),
                        isBroadcaster: _isBroadcaster,
                      ),
                    ),
                  );
                } else {
                  Get.snackbar("Failed", "Enter Broadcast-Id to Join.",
                      backgroundColor: Colors.white,
                      colorText:Colors.blue,
                      snackPosition: SnackPosition.BOTTOM);
                }
              } else {
                Get.snackbar(
                    "Failed", "Microphone Permission Required for Video Call.",
                    backgroundColor: Colors.white,
                    colorText:Colors.blue,
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward, color: Colors.white),
                const SizedBox(
                  width: 20,
                ),
                Text("Join BroadCast",
                    style: regularTxtStyle.copyWith(
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
