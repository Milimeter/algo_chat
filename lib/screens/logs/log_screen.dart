import 'package:flutter/material.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';


import 'widgets/log_list_container.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.white,
        
        body: Padding(
          padding: EdgeInsets.only(left: 15), 
          child: LogListContainer(),
        ),
      ),
    );
  }
}
