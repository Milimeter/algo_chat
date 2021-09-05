import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';
import 'package:login_signup_screen/model/comment.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/callscreens/pickup/pickup_layout.dart';
import 'package:login_signup_screen/widgets/cached_image.dart';


class CommentsScreen extends StatefulWidget {
  final DocumentReference documentReference;
  final UserData user;
  CommentsScreen({this.documentReference, this.user});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController _commentController = TextEditingController();
  UserController _userController = Get.find();
  var _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _commentController?.dispose();
  }

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
            title: Text('Comments', style: TextStyle(color: Colors.black)),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                commentsListWidget(),
                Divider(
                  height: 20.0,
                  color: Colors.grey,
                ),
                commentInputWidget()
              ],
            ),
          ),
       
      ),
    );
  }

  Widget commentInputWidget() {
    return Container(
      height: 55.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          CachedImage(
            //pass to profile of the receiver
            _userController.userData.value.profilePhoto,
            radius: 50,
            isRound: true,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextFormField(
                validator: (input) {
                  if (input.isEmpty) {
                    return "Please enter comment";
                  } else {
                    return null;
                  }
                },
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.blue,
                  )),
                ),
                onFieldSubmitted: (value) {
                  _commentController.text = value;
                },
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(18),
              margin: const EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Entypo.paper_plane, color: Colors.white, size: 23),
            ),
            onTap: () {
              if (_formKey.currentState.validate()) {
                postComment();
              }
            },
          )
        ],
      ),
    );
  }

  postComment() {
    var _comment = Comment(
        comment: _commentController.text,
        timeStamp: FieldValue.serverTimestamp(),
        ownerName: widget.user.name,
        ownerPhotoUrl: widget.user.profilePhoto,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        ownerUid: widget.user.uid);
    widget.documentReference
        .collection("comments")
        .doc()
        .set(_comment.toMap(_comment))
        .whenComplete(() {
      _commentController.text = "";
    });
  }

  Widget commentsListWidget() {
    print("Document Ref : ${widget.documentReference.path}");
    return Flexible(
      child: StreamBuilder(
        stream: widget.documentReference
            .collection("comments")
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: ((context, index) =>
                  commentItem(snapshot.data.docs[index])),
            );
          }
        }),
      ),
    );
  }

  Widget commentItem(DocumentSnapshot snapshot) {
    //   var time;
    //   List<String> dateAndTime;
    //   print('${snapshot.data['timestamp'].toString()}');
    //   if (snapshot.data['timestamp'].toString() != null) {
    //       Timestamp timestamp =snapshot.data['timestamp'];
    //  // print('${timestamp.seconds}');
    //  // print('${timestamp.toDate()}');
    //    time =timestamp.toDate().toString();
    //    dateAndTime = time.split(" ");
    //   }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(snapshot.get('ownerPhotoUrl')),
              radius: 20,
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Row(
            children: <Widget>[
              Text(snapshot.get('ownerName'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(snapshot.get('comment')),
              ),
            ],
          )
        ],
      ),
    );
  }
}
