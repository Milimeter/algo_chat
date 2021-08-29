import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:login_signup_screen/controllers/feeds_controller.dart';
import 'package:login_signup_screen/controllers/user_controller.dart';
import 'package:login_signup_screen/widgets/loading.dart';


import 'package:uuid/uuid.dart';

class UploadFeed extends StatefulWidget {
  final File imageFile;
  UploadFeed({this.imageFile});

  @override
  _UploadFeedState createState() => _UploadFeedState();
}

class _UploadFeedState extends State<UploadFeed> {
  var _locationController;
  var _captionController;
  final _formKey = new GlobalKey<FormState>();
  FocusNode writingTextFocus = FocusNode();
  var uuid = Uuid();
  String uniquekey = "";
  bool isVideo = false;
  FeedsController _feedsController = Get.find();
  UserController _userController = Get.find();

  Address address;

  Map<String, double> currentLocation = Map();
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _captionController = TextEditingController();
    //variables with location assigned as 0.0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    if (widget.imageFile == null) {
      print("+++++++image is null++++++");
      Timer(Duration(milliseconds: 100), () {
        Get.back();
      });
    }
    initPlatformState(); //method to call location
  }

  //method to get Location and save into variables
  initPlatformState() async {
    Address first = await _feedsController.getUserLocation();
    setState(() {
      address = first;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _locationController?.dispose();
    _captionController?.dispose();
  }

  bool _visibility = true;

  void _changeVisibility(bool visibility) {
    setState(() {
      _visibility = visibility;
    });
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    print("performing upload...with============= ");
    if (_validateAndSave()) {
      showLoading();
      writingTextFocus.unfocus();

      var postID = uuid.v4().toString();
      String postImageURL;
      String imageName = "StarX_$uniquekey";
      print(imageName);

      try {
        if (!isVideo) {
          if (widget.imageFile != null) {
            postImageURL = await _feedsController.uploadPostImages(
                postID: postID, postImageFile: widget.imageFile);
          }
        } else {
          if (widget.imageFile != null) {
            postImageURL = await _feedsController.uploadPostVideo(
                postID: postID, postVideoFile: widget.imageFile);
          }
        }

        await _feedsController.uploadPostInFirebase(
            type: "image",
            video: isVideo,
            imageName: imageName,
            postID: postID,
            caption: _captionController.text.trim(),
            ownerId: _userController.userData.value.uid,
            location: locationController.text.trim(),
            imgUrl: postImageURL ?? 'NONE');
        dismissLoading();
        Get.back();
        Get.back();
      } catch (e) {
        print('Error: $e');
        dismissLoading();
        Get.snackbar("Error!", "Error uploading post, try again ");
      }

      print("=======================>>>>>performing upload completed...");
      //Navigator.pop(context);
    }
    print("performing upload exited...");
    // setState(() {
    //   _isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New Post', style: TextStyle(color: Colors.black)),
          backgroundColor: new Color(0xfff8faf8),
          elevation: 1.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 20.0),
              child: GestureDetector(
                child: Text('Share',
                    style: TextStyle(color: Colors.blue, fontSize: 16.0)),
                onTap: () {
                  // To show the CircularProgressIndicator
                  // _changeVisibility(false);
                  validateAndSubmit();
                },
              ),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(widget.imageFile))),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                      child: TextField(
                        controller: _captionController,
                        maxLines: 3,
                        focusNode: writingTextFocus,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Write a caption...',
                        ),
                        // onChanged: ((value) {
                        //   setState(() {
                        //     _captionController.text = value;
                        //   });
                        // }),
                      ),
                    ),
                  )
                ],
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.pin_drop),
                title: Container(
                  width: 250.0,
                  child: TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                        hintText: "Where was this photo taken?",
                        border: InputBorder.none),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: TextField(
              //     controller: _locationController,
              //     // onChanged: ((value) {
              //     //   setState(() {
              //     //     _locationController.text = value;
              //     //   });
              //     // }),
              //     decoration: InputDecoration(
              //       hintText: 'Add location',
              //     ),
              //   ),
              // ),
              Divider(), //scroll view where we will show location to users
              (address == null)
                  ? Container()
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(right: 5.0, left: 5.0),
                      child: Row(
                        children: <Widget>[
                          buildLocationButton(address.featureName),
                          buildLocationButton(address.subLocality),
                          buildLocationButton(address.locality),
                          buildLocationButton(address.subAdminArea),
                          buildLocationButton(address.adminArea),
                          buildLocationButton(address.countryName),
                        ],
                      ),
                    ),
              (address == null) ? Container() : Divider(),
              // Padding(
              //   padding: const EdgeInsets.only(left: 12.0),
              //   child: FutureBuilder(
              //       future: locateUser(),
              //       builder: ((context, AsyncSnapshot<List<Address>> snapshot) {
              //         //  if (snapshot.hasData) {
              //         if (snapshot.hasData) {
              //           print(snapshot.data.first.locality);
              //           return Column(
              //             // alignment: WrapAlignment.start,
              //             children: <Widget>[
              //               GestureDetector(
              //                 child: Chip(
              //                   label: Text(snapshot.data.first.locality),
              //                 ),
              //                 onTap: () {
              //                   setState(() {
              //                     _locationController.text =
              //                         snapshot.data.first.locality;
              //                   });
              //                 },
              //               ),
              //               Padding(
              //                 padding: const EdgeInsets.only(left: 12.0),
              //                 child: GestureDetector(
              //                   child: Chip(
              //                     label: Text(snapshot.data.first.subAdminArea +
              //                         ", " +
              //                         snapshot.data.first.subLocality),
              //                   ),
              //                   onTap: () {
              //                     setState(() {
              //                       _locationController.text =
              //                           snapshot.data.first.subAdminArea +
              //                               ", " +
              //                               snapshot.data.first.subLocality;
              //                     });
              //                   },
              //                 ),
              //               ),
              //             ],
              //           );
              //         } else {
              //           print("Connection State : ${snapshot.connectionState}");
              //           return CircularProgressIndicator();
              //         }
              //       })),
              // ),

              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Offstage(
                  child: CircularProgressIndicator(),
                  offstage: _visibility,
                ),
              )
            ],
          ),
        ),
     
    );
  }

  //method to build buttons with location.
  buildLocationButton(String locationName) {
    if (locationName != null ?? locationName.isNotEmpty) {
      return InkWell(
        onTap: () {
          locationController.text = locationName;
        },
        child: Center(
          child: Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            margin: EdgeInsets.only(right: 3.0, left: 3.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                locationName,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  // Future<List<Address>> locateUser() async {
  //   LocationData currentLocation;
  //   Future<List<Address>> addresses;

  //   var location = new Location();

  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     currentLocation = await location.getLocation();

  //     print(
  //         'LATITUDE : ${currentLocation.latitude} && LONGITUDE : ${currentLocation.longitude}');

  //     // From coordinates
  //     final coordinates =
  //         new Coordinates(currentLocation.latitude, currentLocation.longitude);

  //     addresses = Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   } on PlatformException catch (e) {
  //     print('ERROR : $e');
  //     if (e.code == 'PERMISSION_DENIED') {
  //       print('Permission denied');
  //     }
  //     currentLocation = null;
  //   }
  //   return addresses;
  // }

}
