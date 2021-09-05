import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_signup_screen/constants/strings.dart';
import 'package:login_signup_screen/model/contact.dart';
import 'package:login_signup_screen/model/message.dart';

import 'package:meta/meta.dart';

class ChatMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _messageCollection =
      _firestore.collection(MESSAGES_COLLECTION);

  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<void> addMessageToDb(
    Message message,
  ) async {
    try {
      var map = message.toMap();

      await _messageCollection
          .doc(message.senderId)
          .collection(message.receiverId)
          .add(map);

      addToContacts(senderId: message.senderId, receiverId: message.receiverId);
      updateContactListOrder(
          senderId: message.senderId, receiverId: message.receiverId);

      return await _messageCollection
          .doc(message.receiverId)
          .collection(message.senderId)
          .add(map);
    } catch (e) {
      print(e);
    }
  }

  Future<void> addGifToDb(
    Message message,
  ) async {
    try {
      print(">>>>>>>>>>>>>>>>>>Sending gif Message<<<<<<<<<<<<<<<<<");
      print(message.gif);
      var map = message.toGifMap();

      await _messageCollection
          .doc(message.senderId)
          .collection(message.receiverId)
          .add(map);

      updateContactListOrder(
          senderId: message.senderId, receiverId: message.receiverId);
      print("-------------------done---------------");

      return await _messageCollection
          .doc(message.receiverId)
          .collection(message.senderId)
          .add(map);
    } catch (e) {
      print(e);
    }
  }

  // DocumentReference getContactsDocument({String of, String forContact}) =>
  //     _userCollection
  //         .document(of)
  //         .collection(CONTACTS_COLLECTION)
  //         .document(forContact);
  DocumentReference getContactsDocument({String of, String forContact}) {
    try {
      return _userCollection
          .doc(of)
          .collection(CONTACTS_COLLECTION)
          .doc(forContact);
    } catch (e) {
      print(e);
      return null;
    }
  }

  addToContacts({String senderId, String receiverId}) async {
    try {
      Timestamp currentTime = Timestamp.now();

      await addToSenderContacts(senderId, receiverId, currentTime);
      await addToReceiverContacts(senderId, receiverId, currentTime);
    } catch (e) {
      print(e);
    }
  }

  Future<void> addToSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    try {
      DocumentSnapshot senderSnapshot =
          await getContactsDocument(of: senderId, forContact: receiverId).get();

      if (!senderSnapshot.exists) {
        //does not exists
        Contact receiverContact = Contact(
          uid: receiverId,
          addedOn: currentTime,
          lastMessageDate: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        var receiverMap = receiverContact.toMap(receiverContact);

        await getContactsDocument(of: senderId, forContact: receiverId)
            .set(receiverMap);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addToReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    try {
      DocumentSnapshot receiverSnapshot =
          await getContactsDocument(of: receiverId, forContact: senderId).get();

      if (!receiverSnapshot.exists) {
        //does not exists
        Contact senderContact = Contact(
          uid: senderId,
          addedOn: currentTime,
          lastMessageDate: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        var senderMap = senderContact.toMap(senderContact);

        await getContactsDocument(of: receiverId, forContact: senderId)
            .set(senderMap);
      }
    } catch (e) {
      print(e);
    }
  }

  updateContactListOrder({
    String senderId,
    String receiverId,
  }) async {
    try {
      Timestamp currentTime = Timestamp.now();

      await updateSenderContacts(senderId, receiverId, currentTime);
      await updateReceiverContacts(senderId, receiverId, currentTime);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    try {
      DocumentSnapshot senderSnapshot =
          await getContactsDocument(of: senderId, forContact: receiverId).get();

      if (senderSnapshot.exists) {
        //does not exists
        Contact receiverContact = Contact(
          uid: receiverId,
          addedOn: currentTime,
          lastMessageDate: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        var receiverMap = receiverContact.toMap(receiverContact);

        await getContactsDocument(of: senderId, forContact: receiverId)
            .update(receiverMap);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    try {
      DocumentSnapshot receiverSnapshot =
          await getContactsDocument(of: receiverId, forContact: senderId).get();

      if (receiverSnapshot.exists) {
        //does not exists
        Contact senderContact = Contact(
          uid: senderId,
          addedOn: currentTime,
          lastMessageDate: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        var senderMap = senderContact.toMap(senderContact);

        await getContactsDocument(of: receiverId, forContact: senderId)
            .update(senderMap);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> isTyping({String query, String uid, String ruid}) async {
    if (query.trim().length == 0) {
      await FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(uid)
          .collection(ruid)
          .doc("typingState")
          .update({"isTyping": false});

      //await FirebaseFirestore.instance.collection("users").doc(uid).update({"isTyping": false});
    } else if (query.trim().length == 1 || query.trim().length > 1) {
      await FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(uid)
          .collection(ruid)
          .doc("typingState")
          .update({"isTyping": true});
      // await FirebaseFirestore.instance.collection("users").doc(uid).update({"isTyping": true});
    }
  }

  void setMultipleImageMsg(List<String> url, String receiverId, String senderId,
      Message replyMessage) async {
    try {
      Message message;

      message = Message.multipleImageMessage(
        message: "IMAGES",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: json.encode(url),
        timestamp: Timestamp.now(),
        type: 'multipleimages',
        isRead: false,
        idFrom: senderId,
        replyMessage: replyMessage,
      );

      // create multipleimagemap
      var map = message.toMultipleImageMap();
      addToContacts(senderId: message.senderId, receiverId: message.receiverId);
      updateContactListOrder(
          senderId: message.senderId, receiverId: message.receiverId);

      // var map = Map<String, dynamic>();
      await _messageCollection
          .doc(message.senderId)
          .collection(message.receiverId)
          .add(map);

      _messageCollection
          .doc(message.receiverId)
          .collection(message.senderId)
          .add(map);
    } catch (e) {
      print(e);
    }
  }

  void setImageMsg(
      var url, String receiverId, String senderId, Message replyMessage) async {
    try {
      Message message;

      message = Message.imageMessage(
          message: "IMAGE",
          receiverId: receiverId,
          senderId: senderId,
          photoUrl: url,
          timestamp: Timestamp.now(),
          type: 'image',
          isRead: false,
          idFrom: senderId,
          replyMessage: replyMessage);

      // create imagemap
      var map = message.toImageMap();
      addToContacts(senderId: message.senderId, receiverId: message.receiverId);
      updateContactListOrder(
          senderId: message.senderId, receiverId: message.receiverId);

      // var map = Map<String, dynamic>();
      await _messageCollection
          .doc(message.senderId)
          .collection(message.receiverId)
          .add(map);

      _messageCollection
          .doc(message.receiverId)
          .collection(message.senderId)
          .add(map);
    } catch (e) {
      print(e);
    }
  }

  void setAudioMsg(
      var url, String receiverId, String senderId, Message replyMessage) async {
    try {
      Message message;

      message = Message.audioMessage(
        message: "audio",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'audio',
        isRead: false,
        idFrom: senderId,
        replyMessage: replyMessage,
      );

      // create imagemap
      var map = message.toAudioMap();
      addToContacts(senderId: message.senderId, receiverId: message.receiverId);
      updateContactListOrder(
          senderId: message.senderId, receiverId: message.receiverId);

      // var map = Map<String, dynamic>();
      await _messageCollection
          .doc(message.senderId)
          .collection(message.receiverId)
          .add(map);

      _messageCollection
          .doc(message.receiverId)
          .collection(message.senderId)
          .add(map);
    } catch (e) {
      print(e);
    }
  }

  void setFileMsg(String url, String receiverId, String senderId,
      Message replyMessage) async {
    try {
      Message message;

      message = Message.fileMessage(
        message: "FILE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'file',
        isRead: false,
        idFrom: senderId,
        replyMessage: replyMessage,
      );

      // create imagemap
      var map = message.toFileMap();
      addToContacts(senderId: message.senderId, receiverId: message.receiverId);
      updateContactListOrder(
          senderId: message.senderId, receiverId: message.receiverId);

      await _messageCollection
          .doc(message.senderId)
          .collection(message.receiverId)
          .add(map);

      _messageCollection
          .doc(message.receiverId)
          .collection(message.senderId)
          .add(map);
    } catch (e) {
      print(e);
    }
  }

  void setVideoMsg(String url, String receiverId, String senderId,
      Message replyMessage) async {
    try {
      Message message;

      message = Message.videoMessage(
        message: "VIDEO",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'video',
        isRead: false,
        idFrom: senderId,
        replyMessage: replyMessage,
      );

      // create imagemap
      var map = message.toVideoMap();
      addToContacts(senderId: message.senderId, receiverId: message.receiverId);
      updateContactListOrder(
          senderId: message.senderId, receiverId: message.receiverId);

      await _messageCollection
          .doc(message.senderId)
          .collection(message.receiverId)
          .add(map);

      _messageCollection
          .doc(message.receiverId)
          .collection(message.senderId)
          .add(map);
    } catch (e) {
      print(e);
    }
  }

  // Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
  //     .document(userId)
  //     .collection(CONTACTS_COLLECTION)
  //     .snapshots();
  // Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
  //     .document(userId)
  //     .collection(CONTACTS_COLLECTION)
  //     .orderBy("lastMessageDate", descending: true)
  //     .snapshots();
  Stream<QuerySnapshot> fetchContacts({String userId}) {
    try {
      return _userCollection
          .doc(userId)
          .collection(CONTACTS_COLLECTION)
          .orderBy("lastMessageDate", descending: true)
          .limit(30)
          .snapshots();
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Stream<QuerySnapshot> fetchLastMessageBetween({
  //   @required String senderId,
  //   @required String receiverId,
  // }) =>
  //     _messageCollection
  //         .document(senderId)
  //         .collection(receiverId)
  //         .orderBy("timestamp")
  //         .snapshots();
  Stream<QuerySnapshot> fetchLastMessageBetween({
    @required String senderId,
    @required String receiverId,
  }) {
    try {
      return _messageCollection
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
