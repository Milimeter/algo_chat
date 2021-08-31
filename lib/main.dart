import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/constants/firebase.dart';
import 'package:login_signup_screen/controllers/algorand_controller.dart';
import 'package:login_signup_screen/controllers/app_controller.dart';
import 'package:login_signup_screen/controllers/feeds_controller.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialization.then((value) {
    print("initialized firebase");
  });
  Get.put(UserController());

  Get.put(AppController());
  Get.put(FeedsController());
  Get.put(AlgorandController());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarBrightness: Brightness.light,
    statusBarColor: Colors.blue,
  ));

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    theme: ThemeData(
      brightness: Brightness.light,
      fontFamily: "AvenirNext-Medium",
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: Colors.blue,
    ),
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("AlgoChat"),
        ),
      ),
    );
  }
}
