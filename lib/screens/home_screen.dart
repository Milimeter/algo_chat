import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:login_signup_screen/screens/chat_screen/chat.dart';
import 'package:login_signup_screen/screens/feeds/feeds.dart';
import 'package:login_signup_screen/screens/pageview/algorand_web.dart';
import 'package:login_signup_screen/screens/pageview/developer_settings.dart';

class HomeScreen extends StatefulWidget {
  final int index;
  HomeScreen({this.index});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  int selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    Feeds(),
    ChatListScreen(),
    AlgoWeb(),
    DeveloperSettings(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _widgetOptions
          .elementAt(widget.index == null ? selectedIndex : widget.index),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300],
              hoverColor: Colors.grey[100],
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100],
              color: Colors.black,
              tabs: [
                GButton(
                  icon: Entypo.news,
                  text: 'Home',
                ),
                GButton(
                  icon: Entypo.chat,
                  text: 'Chat',
                ),
                GButton(
                  icon: Entypo.qq,
                  text: 'Solutions',
                ),
                GButton(
                  icon: Entypo.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: selectedIndex,
              onTabChange: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
