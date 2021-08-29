import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/controllers/feeds_controller.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/chat_screen/chat_screen.dart';
import 'package:login_signup_screen/widgets/custom_tile.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // final AuthMethods _authMethods = AuthMethods();
  // UserProvider userProvider;

  List<UserData> userList;
  String query = "";
  TextEditingController searchController = TextEditingController();
  FeedsController _feedsController = Get.find();

  @override
  void initState() {
    super.initState();
    // userProvider = Provider.of<UserProvider>(context, listen: false);

    _feedsController.getCurrentUser().then((User user) {
      _feedsController.fetchAllUsers(user).then((List<UserData> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }

  searchAppBar(BuildContext context) {
    return NewGradientAppBar(
      gradient: LinearGradient(
        colors: [
          // UniversalVariables.gradientColorStart,
          // UniversalVariables.gradientColorEnd,
          Colors.blue,
          Colors.blue
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
            cursorColor: Colors.white,
            autofocus: true,
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => searchController.clear());
                },
              ),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Color(0x88ffffff),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query) {
    final List<UserData> suggestionList = query.isEmpty
        ? []
        : userList != null
            ? userList.where((UserData user) {
                String _getUsername = user.username.toLowerCase();
                String _query = query.toLowerCase();
                String _getName = user.name.toLowerCase();
                bool matchesUsername = _getUsername.contains(_query);
                bool matchesName = _getName.contains(_query);

                return (matchesUsername || matchesName);

                // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) ||
                //     (user.name.toLowerCase().contains(query.toLowerCase()))),
              }).toList()
            : [];

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        UserData searchedUser = UserData(
            uid: suggestionList[index].uid,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            username: suggestionList[index].username,
            firebaseToken: suggestionList[index].firebaseToken);

        return CustomTile(
          color: Colors.white,
          mini: false,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          receiver: searchedUser,
                        )));
          },
          // leading: CachedImage(
          //   searchedUser.profilePhoto,
          //   radius: 50,
          //   isRound: true,
          // ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(searchedUser.profilePhoto ?? ""),
            backgroundColor: Colors.grey,
            radius: 30,
          ),
          title: Text(
            searchedUser.username,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            searchedUser.name,
            style: TextStyle(color: Colors.black54),
          ),
        );
        // return SearchedUserItem(
        //   searchedUser: searchedUser,
        //   isFriend: widget.usersType == null,
        //   isRequest: widget.usersType == UsersType.friendRequests,
        //   onAddFriendPressed: () => _sendFriendRequestCallback(
        //     context,
        //     searchedUser.uid,
        //   ),
        //   onAcceptRequestPressed: () => _acceptFriendRequest(
        //     context,
        //     searchedUser.uid,
        //   ),
        //   onDeleteRequestPressed: () => _deleteRequestPressed(
        //     context,
        //     searchedUser.uid,
        //   ),
        // );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: searchAppBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: buildSuggestions(query),
      ),
    );
  }
}
