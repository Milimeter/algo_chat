import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';
import 'package:login_signup_screen/methods/call_methods.dart';
import 'package:login_signup_screen/model/call.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_screen.dart';

import 'package:get/get.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    @required this.scaffold,
  });
  final UserController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    print(
        "========pickup layout==========${_userController.userData.value.uid}========================");

    return ( userController.userData.value != null)
        ? StreamBuilder<DocumentSnapshot>(
            // stream: callMethods.callStream(uid: userProvider.getUser.uid),
            stream:
                callMethods.callStream(uid: _userController.userData.value.uid),
            builder: (context, snapshot) {
              try {
                if (snapshot.data.exists) {
                  print(
                      "====================data======${snapshot.data.data()}");
                  if (snapshot.hasData && snapshot.data.data() != null) {
                    Call call = Call.fromMap(snapshot.data.data());

                    if (!call.hasDialled) {
                      return PickupScreen(call: call);
                    }
                  }
                }
              } catch (e) {
                print(e);
              }
              return scaffold;
            },
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
