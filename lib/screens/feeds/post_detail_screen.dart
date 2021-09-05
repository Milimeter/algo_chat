import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:login_signup_screen/controllers/feeds_controller.dart';
import 'package:login_signup_screen/model/like.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';
import 'package:login_signup_screen/screens/feeds/comments_screen.dart';
import 'package:login_signup_screen/screens/feeds/likes_screen.dart';
import 'package:login_signup_screen/utils/utilities.dart';
import 'package:login_signup_screen/widgets/show_full_image.dart';


class PostDetailScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final UserData user, currentuser;

  PostDetailScreen({this.documentSnapshot, this.user, this.currentuser});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLiked = false;
  FeedsController _feedsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return  PickupLayout(
          scaffold: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            elevation: 0,
            backgroundColor: new Color(0xfff8faf8),
            title: Text('Photo', style: TextStyle(color: Colors.black)),
          ),
         

          body: Padding(
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
                          onTap: () {},
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
                                  image: NetworkImage(widget.documentSnapshot
                                      .get('postOwnerPhotoUrl')),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )),
                      title: InkWell(
                          onTap: () {},
                          child: Text(
                            widget.documentSnapshot.get('postOwnerName'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      subtitle: Row(
                        children: [
                          widget.documentSnapshot.get('location') != null
                              ? new Text(
                                  widget.documentSnapshot.get('location'),
                                  style: TextStyle(color: Colors.grey),
                                )
                              : Container(),
                          SizedBox(width: 10),
                          Text(
                              Utils.readTimestamp(
                                  widget.documentSnapshot.get('timestamp')),
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
                          postLike(widget.documentSnapshot.reference);
                        } else {
                          setState(() {
                            _isLiked = false;
                          });
                          //saveLikeValue(_isLiked);
                          postUnlike(widget.documentSnapshot.reference);
                        }
                      },
                      onTap: () {
                        //    Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ShowFullImage(
                        //       photoUrl: widget.documentSnapshot.data()['imgUrl'],
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
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
                                      photoUrl: widget.documentSnapshot
                                          .get('imgUrl'),
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
                            // image: DecorationImage(
                            //   image: NetworkImage(list[index].data()['imgUrl']),
                            //   fit: BoxFit.fitWidth,
                            // ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: CachedNetworkImage(
                              imageUrl: widget.documentSnapshot.get('imgUrl'),
                              placeholder: ((context, s) => Center(
                                    child: CircularProgressIndicator(),
                                  )),
                              width: 125.0,
                              // height: 250.0,
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
                                    postLike(widget.documentSnapshot.reference);
                                  } else {
                                    setState(() {
                                      _isLiked = false;
                                    });
                                    //saveLikeValue(_isLiked);
                                    postUnlike(widget.documentSnapshot.reference);
                                  }
                                },
                              ),
                              // Text(
                              //   '2,515', // get likes length
                              //   style: TextStyle(
                              //     fontSize: 14.0,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              SizedBox(width: 10.0),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(FontAwesomeIcons.comment),
                                    color: Colors.black,
                                    iconSize: 30.0,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  CommentsScreen(
                                                    documentReference: widget
                                                        .documentSnapshot
                                                        .reference,
                                                    user: widget.currentuser,
                                                  ))));
                                    },
                                  ),
                                  // Text(
                                  //   '2,515', // get comment length
                                  //   style: TextStyle(
                                  //     fontSize: 14.0,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ],
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
                      future: _feedsController.fetchPostLikeDetails(
                          widget.documentSnapshot.reference),
                      builder: ((context,
                          AsyncSnapshot<List<DocumentSnapshot>> likesSnapshot) {
                        if (likesSnapshot.hasData) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => LikesScreen(
                                            user: widget.currentuser,
                                            documentReference:
                                                widget.documentSnapshot.reference,
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
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
                          child: widget.documentSnapshot.get('caption') != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Wrap(
                                      children: <Widget>[
                                        Text(
                                            widget.documentSnapshot
                                                .get('postOwnerName'),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(widget.documentSnapshot
                                              .get('caption')),
                                        )
                                      ],
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: commentWidget(
                                            widget.documentSnapshot.reference))
                                  ],
                                )
                              : commentWidget(widget.documentSnapshot.reference)),
                    ),
                  ],
                ),
              ),
            ),
          ),
   
      ),
    );
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
                            user: widget.currentuser,
                          ))));
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  void postLike(DocumentReference reference) {
    var _like = Like(
        ownerName: widget.currentuser.name,
        ownerPhotoUrl: widget.currentuser.profilePhoto,
        ownerUid: widget.currentuser.uid,
        timeStamp: FieldValue.serverTimestamp());
    reference
        .collection('likes')
        .doc(widget.currentuser.uid)
        .set(_like.toMap(_like))
        .then((value) {
      print("Post Liked");
    });
  }

  void postUnlike(DocumentReference reference) {
    reference
        .collection("likes")
        .doc(widget.currentuser.uid)
        .delete()
        .then((value) {
      print("Post Unliked");
    });
  }
}
