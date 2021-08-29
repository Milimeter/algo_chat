import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:login_signup_screen/constants/asset_path.dart';
import 'package:login_signup_screen/screens/feeds/upload_feed.dart';
import 'package:scaled_list/scaled_list.dart';

class InstaAddScreen extends StatefulWidget {
  @override
  _InstaAddScreenState createState() => _InstaAddScreenState();
}

class _InstaAddScreenState extends State<InstaAddScreen> {
  File imageFile;
  File _image;

  Future<File> _pickImage(String action) async {
    // action == 'Gallery'
    //     ? selectedImage =
    //         await ImagePicker.pickImage(source: ImageSource.gallery)
    //     : await ImagePicker.pickImage(source: ImageSource.camera);
    if (action == 'Gallery') {
      await pickFromPhone();
    } else {
      await pickFromCamera();
    }

    return _image;
  }

  final picker = ImagePicker();

  pickFromCamera() async {
    // ignore: deprecated_member_use
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print("no image selected");
      }
    });

    await cropImage(_image);
  }

  pickFromPhone() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print("no image selected");
      }
    });

    await cropImage(_image);
  }

  cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path, compressQuality: 100);

    setState(() {
      _image = croppedImage;
    });
  }

  
  showImageDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: ((context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Choose from Gallery'),
                onPressed: () {
                  _pickImage('Gallery').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => UploadFeed(
                                  imageFile: imageFile,
                                ))));
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Take Photo'),
                onPressed: () {
                  _pickImage('Camera').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => UploadFeed(
                                  imageFile: imageFile,
                                ))));
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
  }

  Widget choiceContainer({Color color}) => Container(
        height: MediaQuery.of(context).size.height * 0.60,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                spreadRadius: 0,
                offset: Offset(4, 8),
                color: color.withOpacity(0.5),
              )
            ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text('Create Post',
              style: TextStyle(
                color: Colors.black,
              )),
        ),
        // body: Center(
        //     // ignore: deprecated_member_use
        //     child: RaisedButton.icon(
        //   splashColor: Colors.yellow,
        //   shape: StadiumBorder(),
        //   color: Colors.black,
        //   label: Text(
        //     'Upload Image',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   icon: Icon(
        //     Icons.cloud_upload,
        //     color: Colors.white,
        //   ),
        //   onPressed: _showImageDialog,
        // )),
        body: Center(
          child: ScaledList(
            selectedCardHeightRatio: 0.9,
            unSelectedCardHeightRatio: 0.3,
            itemCount: categories.length,
            itemColor: (index) {
              return kMixedColors[index % kMixedColors.length];
            },
            itemBuilder: (index, selectedIndex) {
              final category = categories[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    hoverColor: Colors.white,
                    onTap: () {
                      switch (index) {
                        case 0:
                          showImageDialog();
                          break;
                        case 1:
                          Get.snackbar("Message", "Feature Coming Soon :)");
                          break;
                        case 2:
                          // video
                          Get.snackbar("Message", "Feature Coming Soon :)");
                          break;
                        case 3:
                          Get.snackbar("Message", "Feature Coming Soon :)");
                          break;
                        case 4:
                          Get.snackbar("Message", "Feature Coming Soon :)");
                          break;
                        default:
                          {
                            print("Invalid choice");
                          }
                          break;
                      }
                    },
                    child: Container(
                      height: selectedIndex == index ? 120 : 80,
                      child: Image.asset(category.image),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    category.name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: selectedIndex == index ? 25 : 20),
                  )
                ],
              );
            },
          ),
        ));
  }

  final List<Color> kMixedColors = [
    Color(0xff71A5D7),
    Color(0xff72CCD4),
    Color(0xffFBAB57),
    Color(0xffF8B993),
    Color(0xff962D17),
    Color(0xffc657fb),
    Color(0xfffb8457),
  ];

  List<Category> categories = [
    Category(image: image, name: "Upload Image", onTap: () {}),
    Category(image: newgroup, name: "Upload Multiple Images", onTap: () {}),
    Category(image: pic3, name: "Upload Video", onTap: () {}),
    Category(image: pic4, name: "Create Polls", onTap: () {}),
    Category(image: support, name: "Create Adverts", onTap: () {}),
  ];
}

class Category {
  final String image;
  final String name;
  final Function onTap;

  Category({@required this.image, @required this.name, @required this.onTap});
}
