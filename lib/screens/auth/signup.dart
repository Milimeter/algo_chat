import 'package:flutter/material.dart';
import 'package:login_signup_screen/constants/controllers.dart';

class SignupPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }

    return false;
  }

  // performs signup
  validateAndSubmit() async {
    print("====================authentication process================");
    if (_validateAndSave()) {
      userController.signUp();
      // _showVerifyEmailSentDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Create an account, It's free ",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    inputFile(
                        label: "name",
                        controller: userController.nameTextEditingController),
                    inputFile(
                        label: "Email",
                        controller: userController.emailTextEditingController),
                    inputFile(
                        label: "Password",
                        obscureText: true,
                        controller:
                            userController.passwordTextEditingController),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border(
                        bottom: BorderSide(color: Colors.black),
                        top: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                      )),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      validateAndSubmit();
                    },
                    color: Color(0xff0095FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Already have an account?"),
                    Text(
                      " Login",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// we will be creating a widget for text field
Widget inputFile(
    {label, obscureText = false, TextEditingController controller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      SizedBox(
        height: 5,
      ),
      TextFormField(
        validator: (val) {
          return val.isEmpty ? "Field Cannot be empty" : null;
        },
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]),
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]))),
      ),
      SizedBox(
        height: 10,
      )
    ],
  );
}
