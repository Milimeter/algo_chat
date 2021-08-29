import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/constants/firebase.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/auth/welcome.dart';
import 'package:login_signup_screen/screens/home_screen.dart';
import 'package:login_signup_screen/utils/utilities.dart';
import 'package:login_signup_screen/widgets/loading.dart';

class UserController extends GetxController {
  static UserController instance = Get.find();
  Rx<User> firebaseUser;
  Rx<UserData> userData = UserData().obs;
  FirebaseAuth auth = FirebaseAuth.instance;

  final box = GetStorage();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneNoTextEditingController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  String usersCollection = "users";

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User user) {
    if (user == null) {
      Get.offAll(() => WelcomeScreen());
    } else {
      userData.bindStream(listenToUser());
      Get.offAll(() => HomeScreen());
    }
  }

  get getuser => userData.bindStream(listenToUser());

  emailAndPasswordSignIn() async {
    showLoading();
    try {
      await auth
          .signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim())
          .then((result) {
        userData.bindStream(listenToUser());
        print("=========================== user sign in =================");
        _clearControllers();
        // Get.offAll(HomePage());
      });
    } catch (e) {
      dismissLoading();
      var error = e.toString().split("]");
      var displayError = error[1];
      Get.snackbar(
        "Error",
        displayError,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        duration: Duration(seconds: 5),
      );
    }
  }

  void signUp() async {
    showLoading();
    try {
      await auth
          .createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim())
          .then((result) {
        String _userId = result.user.uid;
        _addUserToFirestore(_userId);
        _clearControllers();
      });
    } catch (e) {
      dismissLoading();
      var error = e.toString().split("]");
      var displayError = error[1];
      Get.snackbar(
        "Error",
        displayError,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        duration: Duration(seconds: 5),
      );
    }
  }

  _addUserToFirestore(String userId) {
    var followingMap = Map<String, String>();
    followingMap['uid'] = userId;
    var username = Utils.getUsername(emailTextEditingController.text.trim());
    FirebaseFirestore.instance.collection(usersCollection).doc(userId).set({
      "name": nameTextEditingController.text.trim(),
      "uid": userId,
      "email": emailTextEditingController.text.trim(),
      "password": passwordTextEditingController.text.trim(),
      "firebaseToken": appController.token.value,
      "username": username,
      "status": "",
      "state": 0,
      "bio": "",
      "location": "",
      "country": "",
      "groups": [],
      "likedPosts": [],
      "verified": false,
      "followers": '0',
      "following": '0',
      "posts": '0',
      "profile_photo": "https://source.unsplash.com/user/c_v_r",
      "public_address": "",
      "private_key": "",
      "seed_phrase": "",
    }).then((_) {
      firebaseFirestore
          .collection(usersCollection)
          .doc(userId)
          .collection("following")
          .doc(userId)
          .set(followingMap);
      // userData.bindStream(listenToUser());
      print(
          "===========================  user uploaded to database =================");
      // Get.offAll(HomePage());
    });
  }

  Stream<UserData> listenToUser() {
    print("=========================== Listen to user =================");
    print(firebaseUser.value.uid);
    print(firebaseUser.value.email);
    User user = auth.currentUser;
    return FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(firebaseUser.value.uid)
        .snapshots()
        .map((snapshot) => UserData.fromSnapshot(snapshot));
  }

  updateUserData(Map<String, dynamic> data) {
    print("updating user++++++++++++++++++++++");
    FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(firebaseUser.value.uid)
        .update(data)
        .then((value) {
      print(">>>>>>>>>>>>>>>done");
    });
  }

  _clearControllers() {
    emailTextEditingController.clear();
    passwordTextEditingController.clear();
    nameTextEditingController.clear();
    phoneNoTextEditingController.clear();
    nameTextEditingController.clear();
  }

  signOut() async {
    try {
      await auth.signOut();
      // Get.offAll(LoginScreen());
      return true;
    } catch (e) {
      return false;
    }
  }
}
