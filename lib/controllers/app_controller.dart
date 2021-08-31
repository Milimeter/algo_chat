import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_signup_screen/constants/firebase.dart';

class AppController extends GetxController {
  static AppController instance = Get.find();
  static const platform = const MethodChannel('TokenChannel');
  RxString token = "".obs;

  final box = GetStorage();
  @override
  void onReady() {
    super.onReady();
    _getdeviceToken();
    sendData();
    Future.delayed(Duration(milliseconds: 500), () {
      firebaseMessaging.requestPermission(
          sound: true, badge: true, alert: true);
    });
  }

  _getdeviceToken() async {
    await firebaseMessaging.getToken().then((deviceToken) {
      token.value = deviceToken.toString();
      box.write("token", deviceToken.toString());
    });
  }

  Future<void> sendData() async {
    String message;
    try {
      message = await platform.invokeMethod(token.value);
      print(message);
    } on PlatformException catch (e) {
      message = "Failed to get data from native : '${e.message}'.";
    }
  }
}
