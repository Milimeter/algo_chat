import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/methods/chat_methods.dart';
import 'package:login_signup_screen/model/contact.dart';
import 'package:login_signup_screen/model/message.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';
import 'package:login_signup_screen/screens/chat_screen/widget/chat_item.dart';
import 'package:login_signup_screen/screens/chat_screen/widget/search_bar.dart';
import 'package:login_signup_screen/screens/chat_screen/widget/search_user.dart';
import 'package:login_signup_screen/screens/logs/log_screen.dart';
import 'package:login_signup_screen/widgets/algo_app_bar/messenger_app_bar.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  ScrollController _controller;
  bool _isScroll = false;
  ChatMethods _chatMethods = ChatMethods();
  
  _scrollListener() {
    if (_controller.offset > 0) {
      this.setState(() {
        _isScroll = true;
      });
    } else {
      this.setState(() {
        _isScroll = false;
      });
    }
  }

  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
   
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
          scaffold: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: <Widget>[
              _buildAlgoAppBar(_isScroll),
              _buildRootListView(),
            ],
          ),
        ),
      ),
    );
  }

  _buildRootListView() {
    return StreamBuilder<QuerySnapshot>(
        stream: _chatMethods.fetchContacts(
          userId: userController.userData.value.uid,
        ),
        builder: (context, snapshot) {
          try {
            if (snapshot.hasData) {
              var docList = snapshot.data.docs;

              if (docList.isEmpty) {
                return Center(
                    child: Text("You have no messages at the moment"));
              }
              return ListView.builder(
                controller: _controller,
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // if (index == 0) {
                  //   return _buildSearchBar();
                  // } else {
                    try {
                      Contact contact = Contact.fromMap(docList[index].data());

                      return ContactView(contact);
                    } catch (e) {
                      return Text("");
                    }
                //  }
                },
              );
            }
          } catch (e) {
            print(e);
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        });
    // return Expanded(
    //   child: widget(
    //           child: ListView.builder(
    //       padding: EdgeInsets.only(top: 10.0),
    //       controller: _controller,
    //       itemBuilder: (context, index) {
    // if (index == 0) {
    //   return _buildSearchBar();
    // } else if (index == 1) {
    //           return _buildStoriesList();
    //         } else {
    //           return ConversationItem(
    //             friendItem: friendList[index - 2],
    //           );
    //         }
    //       },
    //       itemCount: friendList.length + 2,
    //     ),
    //   ),
    // );
  }

  _buildAlgoAppBar(_isScroll) {
    return (AlgoAppBar(
      isScroll: _isScroll,
      title: 'Chats',
      actions: <Widget>[
        GestureDetector(
          onTap: () {
            Get.to(SearchScreen());
          },
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200,
            ),
            child: Icon(
              FontAwesomeIcons.pen,
              size: 18.0,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> LogScreen()));
          },
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200,
            ),
            child: Icon(
              FontAwesomeIcons.camera,
              size: 18.0,
            ),
          ),
        ),
      ],
    ));
  }

  _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: SearchBar(),
    );
  }
}
