import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  static const ID = "uid";
  static const NAME = "name";
  static const EMAIL = "email";
  static const PASSWORD = "password";
  // static const PHONENO = "phoneNumber";
  static const USERNAME = "username";
  static const STATUS = "status";
  static const STATE = "state";
  static const PROFILEPHOTO = "profile_photo";
  static const GROUPS = "groups";
  static const LIKEDPOSTS = "likedPosts";
  static const FIREBASETOKEN = "firebaseToken";
  static const BIO = "bio";
  static const LOCATION = "location";
  static const COUNTRY = "country";
  static const PUBLICADDRESS = "public_address";
  static const PRIVATEKEY = "private_key";
  static const SEEDPHRASE = "seed_phrase";

  static const VERIFIED = "verified";
  static const FOLLOWING = "following";
  static const FOLLOWERS = "followers";
  static const POSTS = "posts";

  String uid;
  String name;
  String email;
  String password;
  String username;
  String status;
  int state;
  String profilePhoto;
  List groups;
  String firebaseToken;
  String bio;
  String location;
  String country;

  bool verified;
  String following;

  ///herer
  String followers;
  String posts;
  List likedPosts;
  String publicAddress;
  List privateKey;
  List seedPhrase;

  UserData({
    this.uid,
    this.name,
    this.email,
    this.password,
    this.bio,
    this.country,
    this.firebaseToken,
    this.groups,
    this.location,
    this.profilePhoto,
    this.state,
    this.status,
    this.verified,
    this.following,
    this.followers,
    this.posts,
    this.likedPosts,
    this.publicAddress,
    this.privateKey,
    this.seedPhrase,
    this.username,
  });

  UserData.fromSnapshot(DocumentSnapshot snapshot) {
    name = snapshot.get(NAME);
    email = snapshot.get(EMAIL);
    uid = snapshot.get(ID);
    password = snapshot.get(PASSWORD);
    bio = snapshot.get(BIO);
    country = snapshot.get(COUNTRY);
    firebaseToken = snapshot.get(FIREBASETOKEN);
    groups = snapshot.get(GROUPS);
    location = snapshot.get(LOCATION);
    profilePhoto = snapshot.get(PROFILEPHOTO);
    state = snapshot.get(STATE);
    status = snapshot.get(STATUS);
    verified = snapshot.get(VERIFIED);
    following = snapshot.get(FOLLOWING);
    followers = snapshot.get(FOLLOWERS);
    posts = snapshot.get(POSTS);
    likedPosts = snapshot.get(LIKEDPOSTS);
    publicAddress = snapshot.get(PUBLICADDRESS);
    privateKey = snapshot.get(PRIVATEKEY);
    seedPhrase = snapshot.get(SEEDPHRASE);
    username = snapshot.get(USERNAME);
  }
  UserData.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.status = mapData['status'];
    this.state = mapData['state'];
    this.profilePhoto = mapData['profile_photo'];
    this.groups = mapData['groups'];
    this.likedPosts = mapData['likedPosts'];
    this.firebaseToken = mapData['firebaseToken'];
    this.bio = mapData['bio'];
    this.location = mapData['location'];
    this.country = mapData['country'];
    this.password = mapData['password'];

    this.followers = mapData['followers'];
    this.following = mapData['following'];
    this.posts = mapData['posts'];
    this.verified = mapData['verified'];
    this.publicAddress = mapData['public_address'];
    this.privateKey = mapData['private_key'];
    this.seedPhrase = mapData['seed_phrase'];
    this.username = mapData['username'];
  }
}
