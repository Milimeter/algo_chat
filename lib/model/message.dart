import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String receiverId;
  String type;
  String message;
  Timestamp timestamp;
  String photoUrl;
  bool isRead;
  String idFrom;
  Message replyMessage;
  String gif;

  Message({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
    this.isRead,
    this.idFrom,
    this.replyMessage,
  });

  Message.gifMessage({
    this.replyMessage,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isRead,
    this.idFrom,
    this.gif,
  });
  //Will be only called when you wish to send an multiple image
  // named constructor
  Message.multipleImageMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isRead,
    this.idFrom,
    this.replyMessage,
  });
  //Will be only called when you wish to send an image
  // named constructor
  Message.imageMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isRead,
    this.idFrom,
    this.replyMessage,
  });
  Message.audioMessage({
    this.replyMessage,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isRead,
    this.idFrom,
  });
  Message.stickerMessage({
    this.replyMessage,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isRead,
    this.idFrom,
  });

  //Will be only called when you wish to send a file
  // named constructor
  Message.fileMessage({
    this.replyMessage,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isRead,
    this.idFrom,
  });
  //Will be only called when you wish to send a video
  // named constructor
  Message.videoMessage({
    this.replyMessage,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isRead,
    this.idFrom,
  });

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['isRead'] = this.isRead;
    map['idFrom'] = this.idFrom;
    map['replyMessage'] =
        this.replyMessage == null ? null : this.replyMessage.toMap();
    // map['replyMessage'] == null
    //         ? null
    //         : Message.toMap(map['replyMessage']),
    return map;
  }
  Map toGifMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['gif'] = this.gif;
    map['isRead'] = this.isRead;
    map['idFrom'] = this.idFrom;
    map['replyMessage'] =
        this.replyMessage == null ? null : this.replyMessage.toGifMap();
    return map;
  }


  Map toStickerMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['isRead'] = this.isRead;
    map['idFrom'] = this.idFrom;
    map['replyMessage'] =
        this.replyMessage == null ? null : this.replyMessage.toStickerMap();
    return map;
  }

  Map toMultipleImageMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    map['isRead'] = this.isRead;
    map['idFrom'] = this.idFrom;
    map['replyMessage'] = this.replyMessage == null
        ? null
        : this.replyMessage.toMultipleImageMap();
    return map;
  }

  Map toImageMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    map['isRead'] = this.isRead;
    map['idFrom'] = this.idFrom;
    map['replyMessage'] =
        this.replyMessage == null ? null : this.replyMessage.toImageMap();
    return map;
  }

  Map toAudioMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    map['isRead'] = this.isRead;
    map['idFrom'] = this.idFrom;
    map['replyMessage'] =
        this.replyMessage == null ? null : this.replyMessage.toAudioMap();
    return map;
  }

  Map toFileMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    map['isRead'] = this.isRead;
    map['idFrom'] = this.idFrom;
    map['replyMessage'] =
        this.replyMessage == null ? null : this.replyMessage.toFileMap();
    return map;
  }

  Map toVideoMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    map['isRead'] = this.isRead;
    map['idFrom'] = this.idFrom;
    map['replyMessage'] =
        this.replyMessage == null ? null : this.replyMessage.toVideoMap();
    return map;
  }

  // named constructor
  Message.fromMap(Map<String, dynamic> map) {
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    this.photoUrl = map['photoUrl'];
    this.isRead = map['isRead'];
    this.idFrom = map['idFrom'];
    this.replyMessage = map['replyMessage'] == null
        ? null
        : Message.fromMap(map['replyMessage']);
  }
}
