import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_signup_screen/constants/strings.dart';
import 'package:login_signup_screen/model/contact.dart';
import 'package:login_signup_screen/model/user_data.dart';

class ContactMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<void> addContactToDb(UserData sender, UserData receiver) async {
    addToContacts(senderId: sender.uid, receiverId: receiver.uid);
  }

  DocumentReference getContactsDocument({String of, String forContact}) =>
      _userCollection
          .doc(of)
          .collection(CONTACTS_COLLECTION)
          .doc(forContact);

  addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

  Future<void> addToReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId, forContact: senderId)
          .set(senderMap);
    }
  }
   Future<UserData> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(id).get();
      return UserData.fromMap(documentSnapshot.data());
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
  //     .document(userId)
  //     .collection(CONTACTS_COLLECTION)
  //     .snapshots();
  Stream<QuerySnapshot> fetchContacts({String userId}) { 
    try {
      return _userCollection
          .doc(userId)
          .collection(CONTACTS_COLLECTION)
          .snapshots();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
