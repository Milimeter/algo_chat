import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AlgoWeb extends StatefulWidget {
  @override
  _AlgoWebState createState() => _AlgoWebState();
}

class _AlgoWebState extends State<AlgoWeb> {
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          WebView(
            initialUrl: "https://testnet.algoexplorer.io/",
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(),
        ],
      ),
    );
  }
}
