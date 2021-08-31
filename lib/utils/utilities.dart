import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

enum UsersType {
  friendRequests,
  addFriends,
}
InputDecoration textFieldInputDecoration(String input) {
  return InputDecoration(
      hintText: input,
      hintStyle: TextStyle(color: Colors.black),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue[900])),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[900])));
}

final kTitleTextStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w600,
);

final kCaptionTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w100,
);

final List<dynamic> iconImageList = [
  'avatar/001-panda.png',
  'avatar/002-lion.png',
  'avatar/003-tiger.png',
  'avatar/004-bear-1.png',
  'avatar/005-parrot.png',
  'avatar/006-rabbit.png',
  'avatar/007-chameleon.png',
  'avatar/008-sloth.png',
  'avatar/009-elk.png',
  'avatar/010-llama.png',
  'avatar/011-ant-eater.png',
  'avatar/012-eagle.png',
  'avatar/013-crocodile.png',
  'avatar/014-beaver.png',
  'avatar/015-hamster.png',
  'avatar/016-walrus.png',
  'avatar/017-bear.png',
  'avatar/018-cheetah.png',
  'avatar/019-kangaroo.png',
  'avatar/020-duck.png',
  'avatar/021-goose.png',
  'avatar/022-lemur.png',
  'avatar/023-ostrich.png',
  'avatar/024-owl.png',
  'avatar/025-boar.png',
  'avatar/026-penguin.png',
  'avatar/027-camel.png',
  'avatar/028-raccoon.png',
  'avatar/029-hippo.png',
  'avatar/030-monkey.png',
  'avatar/031-meerkat.png',
  'avatar/032-snake.png',
  'avatar/033-zebra.png',
  'avatar/034-donkey.png',
  'avatar/035-bull.png',
  'avatar/036-goat-1.png',
  'avatar/037-goat.png',
  'avatar/038-horse.png',
  'avatar/039-wolf.png',
  'avatar/040-koala.png',
  'avatar/041-hedgehog.png',
  'avatar/042-frog.png',
  'avatar/043-turtle.png',
  'avatar/044-gorilla.png',
  'avatar/045-giraffe.png',
  'avatar/046-deer.png',
  'avatar/047-rhinoceros.png',
  'avatar/048-elephant.png',
  'avatar/049-puma.png',
  'avatar/050-fox.png'
];

class Utils {
  static String getUsername(String email) {
    return "${email.split('@')[0]}";
  }

  final picker = ImagePicker();
  File _image;

  static String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial + lastNameInitial;
  }

  // this is new

  Future<File> pickImage({@required ImageSource source}) async {
    // ignore: deprecated_member_use
    var selectedImage = await picker.getImage(source: source);

    if (selectedImage != null) {
      _image = File(selectedImage.path);
    } else {
      print("no image selected");
    }

    //return await compressImage(_image);
    return _image;
  }

  

  // static int stateToNum(UserState userState) {
  //   switch (userState) {
  //     case UserState.Offline:
  //       return 0;

  //     case UserState.Online:
  //       return 1;

  //     default:
  //       return 2;
  //   }
  // }
  // static int stateToNum(UserState userState) {
  //   switch (userState) {
  //     case UserState.Offline:
  //       return 0;

  //     case UserState.Online:
  //       return 1;

  //     case UserState.Waiting:
  //       return 2;

  //     default:
  //       return 3;
  //   }
  // }

  // static UserState numToState(int number) {
  //   switch (number) {
  //     case 0:
  //       return UserState.Offline;

  //     case 1:
  //       return UserState.Online;

  //     default:
  //       return UserState.Waiting;
  //   }
  // }
  // static UserState numToState(int number) {
  //   switch (number) {
  //     case 0:
  //       return UserState.Offline;

  //     case 1:
  //       return UserState.Online;

  //     case 2:
  //       return UserState.Waiting;

  //     default:
  //       return UserState.Waiting;
  //   }
  // }

  static String formatDateString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(dateTime);
  }

  static String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      if (diff.inHours > 0) {
        time = diff.inHours.toString() + 'h';
      } else if (diff.inMinutes > 0) {
        time = diff.inMinutes.toString() + 'm';
      } else if (diff.inSeconds > 0) {
        time = 'now';
      } else if (diff.inMilliseconds > 0) {
        time = 'now';
      } else if (diff.inMicroseconds > 0) {
        time = 'now';
      } else {
        time = 'now';
      }
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      time = diff.inDays.toString() + 'd';
    } else if (diff.inDays > 6) {
      time = (diff.inDays / 7).floor().toString() + 'w';
    } else if (diff.inDays > 29) {
      time = (diff.inDays / 30).floor().toString() + 'm';
    } else if (diff.inDays > 365) {
      time = '${date.month} ${date.day}, ${date.year}';
    }
    return time;
  }
}
