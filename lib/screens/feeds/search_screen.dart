import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/controllers/feeds_controller.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';
import 'package:login_signup_screen/screens/feeds/friend_profile_screen.dart';
import 'package:login_signup_screen/screens/feeds/post_detail_screen.dart';
import 'package:login_signup_screen/widgets/custom_tile.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<DocumentSnapshot> list = [];
  UserData _user = UserData();
  UserData currentUser;
  List<UserData> usersList = [];
  FeedsController _feedsController = Get.find();

  @override
  void initState() {
    super.initState();
    _feedsController.getCurrentUser().then((user) {
      _user.uid = user.uid;
      _user.name = user.displayName;
      _user.profilePhoto = user.photoURL;
      _feedsController.fetchUserDetailsById(user.uid).then((user) {
        setState(() {
          currentUser = user;
        });
      });
      print("USER : ${user.displayName}");
      _feedsController.retrievePosts(user).then((updatedList) {
        setState(() {
          list = updatedList;
        });
      });
      _feedsController.fetchAllUsers(user).then((list) {
        setState(() {
          usersList = list;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("INSIDE BUILD");
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text('Search', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                  context: context, delegate: DataSearch(userList: usersList));
            },
          )
        ],
      ),
      body: GridView.builder(
          //  shrinkWrap: true,
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
          itemBuilder: ((context, index) {
            print("LIST : ${list.length}");
            return GestureDetector(
              child: CachedNetworkImage(
                imageUrl: list[index].get('imgUrl'),
                placeholder: ((context, s) => Center(
                      child: CircularProgressIndicator(),
                    )),
                width: 125.0,
                height: 125.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                print("SNAPSHOT : ${list[index].reference.path}");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => PostDetailScreen(
                              user: _user,
                              currentuser: currentUser,
                              documentSnapshot: list[index],
                            ))));
              },
            );
          })),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  List<UserData> userList;
  DataSearch({this.userList});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
    // return Center(child: Container(width: 50.0, height: 50.0, color: Colors.red, child: Text(query),));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionsList = query.isEmpty
        ? userList
        : userList.where((p) => p.name.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: ((context, index) => ListTile(
            onTap: () {
              //   showResults(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => FriendsFeedsProfile(
                          name: suggestionsList[index].name))));
            },
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage(suggestionsList[index].profilePhoto),
            ),
            title: Text(suggestionsList[index].name),
          )),
    );
  }
}

class SearchUser extends StatefulWidget {
  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
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
          Colors.blue,
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
                //String _getName = user.name.toLowerCase();
                bool matchesUsername = _getUsername.contains(_query);
                // matchesName = _getName.contains(_query);

                // return (matchesUsername || matchesName);
                return (matchesUsername);

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
                    builder: (context) =>
                        FriendsFeedsProfile(name: suggestionList[index].name)));
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
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
          scaffold: Scaffold(
        backgroundColor: Colors.white,
        appBar: searchAppBar(context),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: buildSuggestions(query),
        ),
      ),
    );
  }
}
