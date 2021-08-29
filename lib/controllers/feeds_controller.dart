import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:login_signup_screen/controllers/app_controller.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';
import 'package:login_signup_screen/model/post.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/widgets/loading.dart';


class FeedsController extends GetxController {
  static FeedsController instance = Get.find();
  AppController _appController = Get.find();
  UserController _userController = Get.find();
  final box = GetStorage();
  Post post;
  FirebaseAuth _auth = FirebaseAuth.instance;
  getUserLocation() async {
    LocationData currentLocation;
    String error;
    Location location = Location();
    try {
      currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      currentLocation = null;
    }
    final coordinates =
        Coordinates(currentLocation.latitude, currentLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("++++++++++++++++++$first++++++++++++");
    return first;
  }

  Future<void> uploadPostInFirebase({
    bool video,
    String imageName,
    String profilePhoto,
    String postID,
    String caption,
    String ownerId,
    String location,
    String imgUrl,
    String type,
  }) async {
    try {
      CollectionReference _collectionRef = FirebaseFirestore.instance
          .collection("users")
          .doc(_userController.userData.value.uid)
          .collection("posts");

      var token;

      if (_appController.token.value == "") {
        token = box.read('token');
      } else {
        token = _appController.token.value;
      }
      post = Post(
        currentUserUid: _userController.userData.value.uid,
        imgUrl: imgUrl,
        caption: caption,
        location: location,
        postOwnerName: _userController.userData.value.name,
        postOwnerPhotoUrl: _userController.userData.value.profilePhoto,
        time: FieldValue.serverTimestamp(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        type: type, // video ? "video" : "image"
        fcmToken: token,
        imageName: imageName,
        postID: postID,
      );
      _collectionRef.add(post.toMap(post));

      // FirebaseFirestore.instance.collection('posts').doc(postID).set({
      //   "type": video ? "video" : "image",
      //   "imageName": imageName,
      //   "fullnameArray": fullname.toLowerCase().split(" "),

      //   'FCMToken': token
      // });
    } catch (e) {
      print(e);
      dismissLoading();
    }
  }

  uploadPostImages(
      {@required String postID, @required File postImageFile}) async {
    try {
      String fileName = 'images/$postID/postImage';
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(postImageFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String postImageURL = await storageTaskSnapshot.ref.getDownloadURL();
      return postImageURL;
    } catch (e) {
      return null;
    }
  }

  static Future<String> uploadAvatar({@required File imageFile}) async {
    try {
      String fileName = 'images/Avatar/Image';
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String postImageURL = await storageTaskSnapshot.ref.getDownloadURL();
      return postImageURL;
    } catch (e) {
      return null;
    }
  }

  uploadPostVideo(
      {@required String postID, @required File postVideoFile}) async {
    try {
      String fileName = 'videos/$postID/postVideo';
      Reference ref =
          FirebaseStorage.instance.ref().child("video").child(fileName);
      UploadTask uploadTask = ref.putFile(
          postVideoFile, SettableMetadata(contentType: 'video/mp4'));
      var storageTaskSnapshot = await uploadTask;
      var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> fetchFollowingUids() async {
    List<String> followingUIDs = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(_userController.userData.value.uid)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      followingUIDs.add(querySnapshot.docs[i].id);
    }

    for (var i = 0; i < followingUIDs.length; i++) {
      print("================DDDD : ${followingUIDs[i]}============");
    }
    return followingUIDs;
  }

  Future<UserData> fetchUserDetailsById(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    return UserData.fromMap(documentSnapshot.data());
  }

  Future<List<DocumentSnapshot>> fetchFeed(User user) async {
    List<String> followingUIDs = [];
    List<DocumentSnapshot> list = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      followingUIDs.add(querySnapshot.docs[i].id);
    }

    print(
        "===============FOLLOWING UIDS : ${followingUIDs.length}================");

    for (var i = 0; i < followingUIDs.length; i++) {
      print(
          "=========================SDDSSD : ${followingUIDs[i]}===================");

      //retrievePostByUID(followingUIDs[i]);
      // fetchUserDetailsById(followingUIDs[i]);

      QuerySnapshot postSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(followingUIDs[i])
          .collection("posts")
          .get();
      // postSnapshot.documents;
      for (var i = 0; i < postSnapshot.docs.length; i++) {
        print("==============dad : ${postSnapshot.docs[i].id}===========");
        list.add(postSnapshot.docs[i]);
        print("=============ads : ${list.length}==========");
      }
    }

    return list;
  }

  Future<List<DocumentSnapshot>> fetchPostLikeDetails(
      DocumentReference reference) async {
    print("REFERENCE : ${reference.path}");
    QuerySnapshot snapshot = await reference.collection("likes").get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchPostCommentDetails(
      DocumentReference reference) async {
    QuerySnapshot snapshot = await reference.collection("comments").get();
    return snapshot.docs;
  }

  Future<String> fetchUidBySearchedName(String name) async {
    String uid;
    List<DocumentSnapshot> uidList = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      uidList.add(querySnapshot.docs[i]);
    }

    print("UID LIST : ${uidList.length}");

    for (var i = 0; i < uidList.length; i++) {
      if (uidList[i].get('name') == name) {
        uid = uidList[i].id;
      }
    }
    print("UID DOC ID: $uid");
    return uid;
  }

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("posts")
        .get();
    return querySnapshot.docs;
  }

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = _auth.currentUser;
    print("EMAIL ID : ${currentUser.email}");
    return currentUser;
  }

  Future<bool> checkIsFollowing(String name, String currentUserId) async {
    bool isFollowing = false;
    String uid = await fetchUidBySearchedName(name);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id == uid) {
        isFollowing = true;
      }
    }
    return isFollowing;
  }

  Future<void> followUser(
      {String currentUserId, String followingUserId}) async {
    var followingMap = Map<String, String>();
    followingMap['uid'] = followingUserId;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .doc(followingUserId)
        .set(followingMap);

    var followersMap = Map<String, String>();
    followersMap['uid'] = currentUserId;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(followingUserId)
        .collection("followers")
        .doc(currentUserId)
        .set(followersMap);
  }

  Future<void> unFollowUser(
      {String currentUserId, String followingUserId}) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .doc(followingUserId)
        .delete();

    return FirebaseFirestore.instance
        .collection("users")
        .doc(followingUserId)
        .collection("followers")
        .doc(currentUserId)
        .delete();
  }

  Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection(label)
        .get();
    return querySnapshot.docs;
  }

  Future<UserData> retrieveUserDetails(User user) async {
    DocumentSnapshot _documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    return UserData.fromMap(_documentSnapshot.data());
  }

  Future<List<DocumentSnapshot>> retrievePosts(User user) async {
    List<DocumentSnapshot> list = [];
    List<DocumentSnapshot> updatedList = [];
    QuerySnapshot querySnapshot;
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      if (snapshot.docs[i].id != user.uid) {
        list.add(snapshot.docs[i]);
      }
    }
    for (var i = 0; i < list.length; i++) {
      querySnapshot = await list[i].reference.collection("posts").get();
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        updatedList.add(querySnapshot.docs[i]);
      }
    }
    // fetchSearchPosts(updatedList);
    print("UPDATED LIST LENGTH : ${updatedList.length}");
    return updatedList;
  }

  Future<List<UserData>> fetchAllUsers(User user) async {
    List<UserData> userList = [];
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        userList.add(UserData.fromMap(querySnapshot.docs[i].data()));
        //userList.add(querySnapshot.documents[i].data[User.fromMap(mapData)]);
      }
    }
    print("USERSLIST : ${userList.length}");
    return userList;
  }
  // Future<User> getCurrentUser() async {
  //   User currentUser;
  //   currentUser = _auth.currentUser;
  //   return currentUser;
  // }
}
