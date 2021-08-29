
import 'package:flutter/material.dart';
import 'package:login_signup_screen/constants/controllers.dart';
import 'package:login_signup_screen/methods/chat_methods.dart';
import 'package:login_signup_screen/methods/contact_methods.dart';
import 'package:login_signup_screen/model/contact.dart';
import 'package:login_signup_screen/model/user_data.dart';
import 'package:login_signup_screen/screens/chat_screen/chat_screen.dart';
import 'package:login_signup_screen/screens/chat_screen/widget/last_message.dart';
import 'package:login_signup_screen/widgets/cached_image.dart';
import 'package:login_signup_screen/widgets/custom_tile.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

class ContactView extends StatefulWidget {
  final Contact contact;

  ContactView(this.contact);

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final ContactMethods _contactMethods = ContactMethods();

  @override
  Widget build(BuildContext context) {
    print(
        "=======contact uid=================${widget.contact.uid}=============");
    return FutureBuilder<UserData>(
      future: _contactMethods.getUserDetailsById(widget.contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = snapshot.data;

          return ViewLayout(
            contact: user,
          );
        }
        // return Center(
        //     child: SpinKitFadingFour(
        //   color: UniversalVariables.blueColor,
        // ));
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.white,
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ViewLayout extends StatefulWidget {
  final UserData contact;

  ViewLayout({
    @required this.contact,
  });

  @override
  _ViewLayoutState createState() => _ViewLayoutState();
}

class _ViewLayoutState extends State<ViewLayout> {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {

    return CustomTile(
      color: Colors.white,
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: widget.contact,
            ),
          )),
      title: Text(
        (widget.contact != null ? widget.contact.name : null) != null
            ? widget.contact.name
            : "..",
        style: TextStyle(
          fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: userController.userData.value.uid,
          receiverId: widget.contact.uid,
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShowFullImage(
                      photoUrl: widget.contact.profilePhoto))),
          child: CachedImage(
            //pass to hero widget
            widget.contact.profilePhoto,
            radius: 80,
            isRound: true,
          ),
        ),
      ),
      trailing: LastMessageTimeContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: userController.userData.value.uid,
          receiverId: widget.contact.uid,
        ),
      ),
    );
  }
}

class ShowFullImage extends StatelessWidget {
  final String photoUrl;

  const ShowFullImage({Key key, this.photoUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: photoUrl == null || photoUrl.isEmpty
            ? AssetImage('assets/placeholder.png')
            : NetworkImage(photoUrl),
        loadingBuilder: (ctx, loadingProgress) {
          if (loadingProgress == null) return Container();

          return FractionallySizedBox(
            widthFactor: loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes,
            child: Container(
              color: Colors.grey[400].withOpacity(0.3),
            ),
            alignment: Alignment.centerLeft,
          );
        },
      ),
    );
    // return Container(
    //     child: Image.network(
    //   photoUrl,
    // ));
  }
}