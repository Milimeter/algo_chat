import 'package:flutter/material.dart';

class FloatingColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                //gradient: UniversalVariables.fabGradient,
                color: Colors.blue),
            child: Icon(
              Icons.dialpad,
              color: Colors.white,
              size: 25,
            ),
            padding: EdgeInsets.all(15),
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                  width: 2,
                  color: Color(0xff0184dc),
                )),
            child: Icon(
              Icons.add_call,
              color: Color(0xff0184dc),
              size: 25,
            ),
            padding: EdgeInsets.all(15),
          )
        ],
      ),
    );
  }
}
