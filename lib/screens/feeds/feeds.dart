import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:login_signup_screen/controllers/feeds_controller.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';
import 'package:login_signup_screen/model/like.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';
import 'package:login_signup_screen/screens/feeds/LiveStream/choose_call.dart';
import 'package:login_signup_screen/screens/feeds/add_screen.dart';
import 'package:login_signup_screen/screens/feeds/comments_screen.dart';
import 'package:login_signup_screen/screens/feeds/friend_profile_screen.dart';
import 'package:login_signup_screen/screens/feeds/likes_screen.dart';
import 'package:login_signup_screen/screens/feeds/profile_screen.dart';
import 'package:login_signup_screen/screens/feeds/search_screen.dart';
import 'package:login_signup_screen/utils/utilities.dart';
import 'package:login_signup_screen/widgets/cached_image.dart';
import 'package:login_signup_screen/widgets/show_full_image.dart';

class Feeds extends StatefulWidget {
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  UserData currentUser, user, followingUser;
  IconData icon;
  Color color;
  List<UserData> usersList = [];
  Future<List<DocumentSnapshot>> _future;
  bool _isLiked = false;
  List<String> followingUIDs = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  UserController _userController = Get.find();
  FeedsController _feedsController = Get.find();
  
  bool ready = false;

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  @override
  void initState() {
    super.initState();
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    User currentUser = await _feedsController.getCurrentUser();
    UserData user =
        await _feedsController.fetchUserDetailsById(currentUser.uid);
    setState(() {
      this.currentUser = user;
    });

    followingUIDs = await _feedsController.fetchFollowingUids();

    for (var i = 0; i < followingUIDs.length; i++) {
      print("DSDASDASD : ${followingUIDs[i]}");
      // _future = _repository.retrievePostByUID(followingUIDs[i]);
      this.user = await _feedsController.fetchUserDetailsById(followingUIDs[i]);
      print("user : ${this.user.uid}");
      usersList.add(this.user);
      print("USERSLIST : ${usersList.length}");

      for (var i = 0; i < usersList.length; i++) {
        setState(() {
          followingUser = usersList[i];
          print("FOLLOWING USER : ${followingUser.uid}");
        });
      }
    }
    _future = _feedsController.fetchFeed(currentUser);
  }

  bool builds = false;
  set() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _handleRefresh() {
      final Completer<void> completer = Completer<void>();

      fetchFeed().then((value) {
        setState(() {});
      });

      set();
      // _refreshIndicatorKey.currentState.;

      Timer(const Duration(seconds: 3), () {
        completer.complete();
      });
      return completer.future;
    }

    print("=============build called ==============");
    return PickupLayout(
          scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: new Color(0xfff8faf8),
          centerTitle: true,
          elevation: 1.0,
          // leading: new Icon(Icons.camera_alt),
          title: GestureDetector(
            onTap: () => Get.to(ProfileScreen()),
            child: CachedImage(
              //pass to profile of the receiver
              _userController.userData.value.profilePhoto,
              radius: 50,
              isRound: true,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: Icon(
                  Icons.live_tv,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => ChooseCall())));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: Icon(
                  Entypo.magnifying_glass,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => Search())));
                },
              ),
            )
          ],
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => InstaAddScreen(),
              ));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50)),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 25,
              ),
              padding: EdgeInsets.all(15),
            ),
          ),
        ),
        body: Container(
          child: currentUser != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: LiquidPullToRefresh(
                    backgroundColor: Colors.blue[900],
                    key: _refreshIndicatorKey,
                    onRefresh: () => _handleRefresh(),
                    showChildOpacityTransition: false,
                    child: postImagesWidget(),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  Widget postImagesWidget() {
    return FutureBuilder(
      future: _future,
      builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          print("FFFF : ${followingUser.uid ?? " no follower"}");
          if (snapshot.data.length == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "You current have no post feed. Search for users and follow them to see their posts",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  //shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: ((context, index) => listItem(
                        list: snapshot.data,
                        index: index,
                        user: followingUser,
                        currentUser: currentUser,
                      )));
            } else {
              print("not done");
              return Center(
                child: Text(
                  "You current have no post feed. Search for users and follow them to see their posts",
                  textAlign: TextAlign.center,
                ),
              );
            }
          }
        } else {
          print("No Posts");
          // return Center(
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: AutoSizeText(
          //       "You current have no post feed. Search for users and follow them to see their posts",
          //       textAlign: TextAlign.center,
          //     ),
          //   ),
          // );

          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }

  Widget listItem(
      {List<DocumentSnapshot> list,
      UserData user,
      UserData currentUser,
      int index}) {
    print("dadadadad : ${user.uid}");
    if (list[index].get('type') == "image") {
      return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => FriendsFeedsProfile(
                                      name: list[index].get('postOwnerName'),
                                    ))));
                      },
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0.0, 2.0),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          child: ClipOval(
                            child: Image(
                              width: 50.0,
                              height: 50.0,
                              image: NetworkImage(
                                  list[index].get('postOwnerPhotoUrl')),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )),
                  title: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => FriendsFeedsProfile(
                                      name: list[index].get('postOwnerName')
                                    ))));
                      },
                      child: Text(
                        list[index].get('postOwnerName'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  subtitle: Row(
                    children: [
                      list[index].get('location') != null
                          ? new Text(
                              list[index].get('location'),
                              style: TextStyle(color: Colors.grey),
                            )
                          : Container(),
                      SizedBox(width: 10),
                      Text(Utils.readTimestamp(list[index].get('timestamp')),
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_horiz),
                    color: Colors.black,
                    onPressed: () => print('More'),
                  ),
                ),
                InkWell(
                  onDoubleTap: () {
                    if (!_isLiked) {
                      setState(() {
                        _isLiked = true;
                      });
                      // saveLikeValue(_isLiked);
                      postLike(list[index].reference, currentUser);
                    } else {
                      setState(() {
                        _isLiked = false;
                      });
                      //saveLikeValue(_isLiked);
                      postUnlike(list[index].reference, currentUser);
                    }
                  },
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ShowFullImage(
                    //       photoUrl: list[index].data()['imgUrl'],
                    //     ),
                    //   ),
                    // );
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => ViewPostScreen(post: posts[index]),
                    //   ),
                    // );
                  },
                  child: FocusedMenuHolder(
                    menuWidth: MediaQuery.of(context).size.width * 0.50,
                    blurSize: 5.0,
                    menuItemExtent: 45,
                    menuBoxDecoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    duration: Duration(milliseconds: 100),
                    animateMenuItems: true,
                    blurBackgroundColor: Colors.black54,
                    bottomOffsetHeight: 100,
                    openWithTap: true,
                    menuItems: <FocusedMenuItem>[
                      FocusedMenuItem(
                          title: Text("View media"),
                          trailingIcon: Icon(Entypo.documents),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowFullImage(
                                  photoUrl: list[index].get('imgUrl'),
                                ),
                              ),
                            );
                          }),
                      FocusedMenuItem(
                          title: Text("Share Feed"),
                          trailingIcon: Icon(Entypo.paper_plane),
                          onPressed: () {}),
                      FocusedMenuItem(
                          title: Text("Download Feed"),
                          trailingIcon: Icon(Entypo.download),
                          onPressed: () {}),
                      FocusedMenuItem(
                          title: Text("Unfollow User",
                              style: TextStyle(color: Colors.redAccent)),
                          trailingIcon:
                              Icon(Entypo.log_out, color: Colors.redAccent),
                          onPressed: () async {}),
                    ],
                    onPressed: () {},
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      width: double.infinity,
                      height: 400.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200],
                            offset: Offset(0.0, 8.0),
                            blurRadius: 8.0,
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(list[index].get('imgUrl')),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: _isLiked
                                ? Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  )
                                : Icon(
                                    FontAwesomeIcons.heart,
                                    color: null,
                                  ),
                            iconSize: 30.0,
                            onPressed: () {
                              if (!_isLiked) {
                                setState(() {
                                  _isLiked = true;
                                });
                                // saveLikeValue(_isLiked);
                                postLike(list[index].reference, currentUser);
                              } else {
                                setState(() {
                                  _isLiked = false;
                                });
                                //saveLikeValue(_isLiked);
                                postUnlike(list[index].reference, currentUser);
                              }
                            },
                          ),
                          // LikeButton(
                          //   size: buttonSize,
                          //   likeCount: likeCount,
                          //  // key: _globalKey,
                          //   countBuilder:
                          //       (int? count, bool isLiked, String text) {
                          //     final ColorSwatch<int> color =
                          //         isLiked ? Colors.pinkAccent : Colors.grey;
                          //     Widget result;
                          //     if (count == 0) {
                          //       result = Text(
                          //         'love',
                          //         style: TextStyle(color: color),
                          //       );
                          //     } else
                          //       result = Text(
                          //         count! >= 1000
                          //             ? (count / 1000.0).toStringAsFixed(1) + 'k'
                          //             : text,
                          //         style: TextStyle(color: color),
                          //       );
                          //     return result;
                          //   },
                          //   likeCountAnimationType: likeCount < 1000
                          //       ? LikeCountAnimationType.part
                          //       : LikeCountAnimationType.none,
                          //   likeCountPadding: const EdgeInsets.only(left: 15.0),
                          //   onTap: onLikeButtonTapped,
                          // ),
                          SizedBox(width: 10.0),
                          IconButton(
                            icon: Icon(FontAwesomeIcons.comment),
                            color: Colors.black,
                            iconSize: 30.0,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => CommentsScreen(
                                            documentReference:
                                                list[index].reference,
                                            user: currentUser,
                                          ))));
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.bookmark_border),
                        iconSize: 30.0,
                        onPressed: () => print('Save post'),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: _feedsController
                      .fetchPostLikeDetails(list[index].reference),
                  builder: ((context,
                      AsyncSnapshot<List<DocumentSnapshot>> likesSnapshot) {
                    if (likesSnapshot.hasData) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => LikesScreen(
                                        user: currentUser,
                                        documentReference:
                                            list[index].reference,
                                      ))));
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: likesSnapshot.data.length > 1
                                ? Text(
                                    "Liked by ${likesSnapshot.data[0].get('ownerName')} and ${(likesSnapshot.data.length - 1).toString()} others",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : Text(likesSnapshot.data.length == 1
                                    ? "Liked by ${likesSnapshot.data[0].get('ownerName')}"
                                    : "0 Likes"),
                          ),
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      child: list[index].get('caption') != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Wrap(
                                  children: <Widget>[
                                    Text(list[index].get('postOwnerName'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child:
                                          Text(list[index].get('caption')),
                                      // child: LinkifyText(
                                      //   list[index].get('caption'),
                                      //   textColor: Colors.black54,
                                      //   //fontSize: 15,
                                      //   linkColor: Colors.blue[700],
                                      //   isLinkNavigationEnable: true,
                                      //   // textAlign: TextAlign.start,
                                      //   // style: TextStyle(fontSize: 15.0, color: Colors.white)
                                      // ),
                                    )
                                  ],
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: commentWidget(list[index].reference))
                              ],
                            )
                          : commentWidget(list[index].reference)),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Map options = list[index].get('options');
      return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => FriendsFeedsProfile(
                                      name: list[index].get('postOwnerName'),
                                    ))));
                      },
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0.0, 2.0),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          child: ClipOval(
                            child: Image(
                              width: 50.0,
                              height: 50.0,
                              image: NetworkImage(
                                  list[index].get('postOwnerPhotoUrl')),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )),
                  title: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => FriendsFeedsProfile(
                                      name: list[index].get('postOwnerName')
                                    ))));
                      },
                      child: Text(
                        list[index].get('postOwnerName'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  subtitle: Row(
                    children: [
                      list[index].get('location') != null
                          ? new Text(
                              list[index].get('location'),
                              style: TextStyle(color: Colors.grey),
                            )
                          : Container(),
                      SizedBox(width: 10),
                      Text(Utils.readTimestamp(list[index].get('timestamp')),
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_horiz),
                    color: Colors.black,
                    onPressed: () => print('More'),
                  ),
                ),
                // Polls(
                //   // children: [
                //   //   Polls.options(title: 'Java', value: option1),
                //   //   Polls.options(title: 'Kotlin', value: option2),
                //   //   Polls.options(title: 'Flutter', value: option3),
                //   //   Polls.options(title: 'React Native', value: option4),
                //   // ],
                //   children: options.entries
                //       .map((e) => Polls.options(title: e.value, value: e.key))
                //       .toList(),
                //   question: Text(
                //     'Which Andriod App Development technology used?',
                //     style: TextStyle(fontSize: 17),
                //   ),
                //   currentUser: _userController.userData.value.email,
                //   creatorID: list[index].data()['creatorID'],
                //   voteData: list[index].data()['usersWhoVoted'],
                //   userChoice: list[index].data()['usersWhoVoted']
                //       [_userController.userData.value.email],
                //   onVoteBackgroundColor: Colors.cyan,
                //   leadingBackgroundColor: Colors.cyan,
                //   backgroundColor: Colors.white,
                //   onVote: (choice) {
                //     // print(choice);
                //     // setState(() {
                //     //   list[index].data()['usersWhoVoted'][_userController.userData.value.email] = choice;
                //     // });
                //     // if (choice == 1) {
                //     //   setState(() {
                //     //     option1 += 1.0;
                //     //   });
                //     // }
                //     // if (choice == 2) {
                //     //   setState(() {
                //     //     option2 += 1.0;
                //     //   });
                //     // }
                //     // if (choice == 3) {
                //     //   setState(() {
                //     //    // option3 += 1.0;
                //     //   });
                //     // }
                //     // if (choice == 4) {
                //     //   setState(() {
                //     //     option4 += 1.0;
                //     //   });
                //     // }
                //   },
                // ),
              
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget commentWidget(DocumentReference reference) {
    return FutureBuilder(
      future: _feedsController.fetchPostCommentDetails(reference),
      builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            child: Text(
              'View all ${snapshot.data.length} comments',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => CommentsScreen(
                            documentReference: reference,
                            user: currentUser,
                          ))));
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  void postLike(DocumentReference reference, UserData currentUser) {
    var _like = Like(
        ownerName: currentUser.name,
        ownerPhotoUrl: currentUser.profilePhoto,
        ownerUid: currentUser.uid,
        timeStamp: FieldValue.serverTimestamp());
    reference
        .collection('likes')
        .doc(currentUser.uid)
        .set(_like.toMap(_like))
        .then((value) {
      print("Post Liked");
    });
  }

  void postUnlike(DocumentReference reference, UserData currentUser) {
    reference.collection("likes").doc(currentUser.uid).delete().then((value) {
      print("Post Unliked");
    });
  }
}
