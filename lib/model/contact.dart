import 'package:cloud_firestore/cloud_firestore.dart';

class Contact  {
  String uid;
  Timestamp addedOn;
  String lastMessageDate;
  bool blocked;
  
  

  Contact({
    this.uid,
    this.addedOn,
    this.lastMessageDate,
    this.blocked,
  });

  Map toMap(Contact contact) {
    var data = Map<String, dynamic>();
    data['contact_id'] = contact.uid;
    data['added_on'] = contact.addedOn;
    data['lastMessageDate'] = contact.lastMessageDate;
    data['blocked'] = contact.blocked;
    return data;
  }

  Contact.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['contact_id'];
    this.addedOn = mapData["added_on"];
    this.lastMessageDate = mapData["lastMessageDate"];
    this.blocked = mapData["blocked"];
  }
}


