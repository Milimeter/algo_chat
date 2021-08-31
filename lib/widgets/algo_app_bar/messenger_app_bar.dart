import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/screens/home_screen.dart';

import 'app_bar_network_rounded_image.dart';
import 'app_bar_title.dart';

// ignore: must_be_immutable
class AlgoAppBar extends StatefulWidget {
  // ignore: deprecated_member_use
  List<Widget> actions = List<Widget>(0);
  String title;
  bool isScroll;
  bool isBack;

  AlgoAppBar({this.actions, this.title = '', this.isScroll, this.isBack});

  @override
  _AlgoAppBarState createState() => _AlgoAppBarState();
}

class _AlgoAppBarState extends State<AlgoAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.0,
      padding: EdgeInsets.only(right: 12.0, top: 25.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: widget.isScroll ? Colors.black12 : Colors.white,
          offset: Offset(0.0, 1.0),
          blurRadius: 10.0,
        ),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 16.0,
              ),
              InkWell(
                onTap: () {
                  Get.to(HomeScreen(index: 3));
                },
                child: AppBarNetworkRoundedImage(
                  imageUrl: userController.userData.value.profilePhoto,
                ),
              ),
              SizedBox(
                width: 8.0,
              ),
              AppBarTitle(
                text: widget.title,
              ),
            ],
          ),
          Container(
            child: Row(
              children: widget.actions
                  .map((c) => Container(
                        padding: EdgeInsets.only(left: 16.0),
                        child: c,
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
