import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/controllers/feeds_controller.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';
import 'package:login_signup_screen/screens/feeds/friend_profile_screen.dart';
import 'package:login_signup_screen/screens/feeds/profile_screen.dart';


class LikesScreen extends StatefulWidget {
  final DocumentReference documentReference;
  final UserData user;
  LikesScreen({this.documentReference, this.user});

  @override
  _LikesScreenState createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  FeedsController _feedsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return  PickupLayout(
          scaffold: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            backgroundColor: new Color(0xfff8faf8),
            title: Text('Likes', style: TextStyle(color: Colors.black)),
          ),
          body: FutureBuilder(
            future:
                _feedsController.fetchPostLikeDetails(widget.documentReference),
            builder: ((context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: ((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0, top: 16.0),
                      child: ListTile(
                        title: GestureDetector(
                          onTap: () {
                            snapshot.data[index].get('ownerName') ==
                                    widget.user.name
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => ProfileScreen())))
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            FriendsFeedsProfile(
                                              name: snapshot.data[index]
                                                  .get('ownerName'),
                                            ))));
                          },
                          child: Text(
                            snapshot.data[index].get('ownerName'),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          ),
                        ),
                        leading: GestureDetector(
                          onTap: () {
                            snapshot.data[index].get('ownerName')==
                                    widget.user.name
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => ProfileScreen())))
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            FriendsFeedsProfile(
                                              name: snapshot.data[index]
                                                  .get('ownerName'),
                                            ))));
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                snapshot.data[index].get('ownerPhotoUrl')),
                            radius: 30.0,
                          ),
                        ),
                        // trailing:
                        //     snapshot.data[index].data['ownerUid'] != widget.user.uid
                        //         ? buildProfileButton(snapshot.data[index].data['ownerName'])
                        //         : null,
                      ),
                    );
                  }),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('No Likes found'),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
          ),
        
      ),
    );
  }
}
