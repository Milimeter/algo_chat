import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:login_signup_screen/constants/asset_path.dart';
import 'package:login_signup_screen/constants/firebase.dart';
import 'package:login_signup_screen/widgets/loading.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

algoReceiveDialog(context, {String uid}) {
  return showDialog(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  blurRadius: 1,
                  spreadRadius: 1,
                  offset: Offset(4, 8),
                  color: Colors.grey[100],
                ),
              ]),
          child: Column(
            children: [
              Center(
                child: PrettyQr(
                  image: AssetImage(logo),
                  typeNumber: 3,
                  size: 250,
                  data: uid,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  roundEdges: true,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(55),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 1,
                        spreadRadius: 1,
                        offset: Offset(4, 8),
                        color: Colors.grey[100],
                      ),
                    ]),
                child: Text(
                  "Close",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        );
      });
}

algoSendDialog(context, {String uid}) {
  return showDialog(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          margin: EdgeInsets.all(35),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  blurRadius: 1,
                  spreadRadius: 1,
                  offset: Offset(4, 8),
                  color: Colors.grey[100],
                ),
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tell your friends to scan the bar code below",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
              ),
              SizedBox(height: 35),
              Align(
                alignment: Alignment.topCenter,
                child: PrettyQr(
                  image: AssetImage(logo),
                  typeNumber: 3,
                  size: 250,
                  data: uid,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  roundEdges: true,
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  //width: MediaQuery.of(context).size.height * 0.5,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(55),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 1,
                          offset: Offset(4, 8),
                          color: Colors.grey[100],
                        ),
                      ]),
                  child: Center(
                    child: Text(
                      "Close",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      });
}

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Scan Barcode to send",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
              onPressed: () {},
              icon: Icon(FontAwesomeIcons.arrowAltCircleRight),
              label: Text("Skip"))
        ],
      ),
      body: Column(
        children: <Widget>[
          // Expanded(
          //   flex: 5,
          //   child: QRView(
          //     key: qrKey,
          //     onQRViewCreated: _onQRViewCreated,
          //   ),
          // ),
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      result = null;
                    });
                    controller.resumeCamera();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    width: 100,
                    //height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[200],
                          blurRadius: 0.1,
                          spreadRadius: 0.0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      result == null ? "Scan Code" : "Scan Again",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 22),
                result != null
                    ? GestureDetector(
                        onTap: () {
                          if (result != null) {
                            showLoading();
                            print(result.code);
                            var id = result.code;
                            firebaseFirestore
                                .collection("users")
                                .doc(id)
                                .get()
                                .then((result) {
                              if (result.exists) {
                                var address = result.data()["public_address"];
                                // var profilephoto =
                                //     result.data()["profile_photo"];
                                // var name = result.data()["name"];
                                // var username = result.data()["username"];
                                dismissLoading();
                                // UserData searchedUser = UserData(
                                //     uid: id,
                                //     profilePhoto: profilephoto,
                                //     name: name,
                                //     username: username,
                                //     firebaseToken: token);

                                // Get.off(ChatScreen(
                                //   receiver: searchedUser,
                                // ));
                              } else {
                                dismissLoading();
                                Get.snackbar("Error!", "User Does not exist");
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[200],
                                blurRadius: 0.1,
                                spreadRadius: 0.0,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            "Continue",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : SizedBox(),
                // Center(
                //   child: (result != null)
                //       ? Text(' Data: ${result.code}')
                //       : Text('Scan a code'),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blue[900],
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      setState(() {
        result = scanData;
      });
      print(result.code);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
