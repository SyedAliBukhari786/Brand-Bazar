import 'package:brandbazaar/brandSignup.dart';
import 'package:brandbazaar/frontPage.dart';
import 'package:brandbazaar/userSignup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

import 'brandDashboard.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  bool _showPassword = false;

  String uidd = "";
  String aaa = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              Image.asset('assets/topBar.png',
                  fit: BoxFit.contain,
                  height: MediaQuery.of(context).size.height * 0.07),
              Text(
                " BRAND BAZAAR",
                style: TextStyle(
                  fontFamily: 'TitilliumWeb',
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.026,
                  color: Color(0xFF082c50),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.6),
              Text(
                "USER LOGIN",
                style: TextStyle(
                  fontFamily: 'TitilliumWeb',
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.016,
                  color: Color(0xFF082c50),
                ),
              ),
            ]),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/brandLogin.png',
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: MediaQuery.of(context).size.width * 0.35),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          this.context,
                          MaterialPageRoute(builder: (context) => UserSignup()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Not a member yet?   ",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.012),
                          children: [
                            TextSpan(
                              text: "Sign up!",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.012),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      obscureText: !_showPassword,
                      controller: _pass,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Flexible(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.08,
                        height: MediaQuery.of(context).size.height * 0.07,
                        margin: EdgeInsets.all(10),
                        child: OutlinedButton(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.015,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            if (_email.text.isEmpty || _email.text == '') {
                              final SnackBar snackBar = SnackBar(
                                content: Text("Enter Email"),
                                duration: Duration(seconds: 5),
                                backgroundColor: Colors.red,
                                action: SnackBarAction(
                                  label: 'Close',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else if (!EmailValidator.validate(_email.text)) {
                              final snackBar = SnackBar(
                                content: Text('Enter a valid email address'),
                                duration: Duration(seconds: 5),
                                backgroundColor: Colors.red,
                                action: SnackBarAction(
                                  label: 'Close',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else if (_pass.text.isEmpty || _pass.text == '') {
                              final SnackBar snackbar = SnackBar(
                                content: Text('Enter Password'),
                                duration: Duration(seconds: 5),
                                backgroundColor: Colors.red,
                                action: SnackBarAction(
                                  label: 'Close',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackbar);
                            } else {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: _email.text, password: _pass.text)
                                  .then((authResult) async {
                                // Successful sign-in, proceed with navigation

                                Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                      builder: (context) => FrontPage()),
                                );

                                _pass.clear();
                                _email.clear();
                              }).catchError((e) {
                                // Handle sign-in error here
                                print(e.toString());
                                final SnackBar snackbar = SnackBar(
                                  content: Text("Some error occurred"),
                                  duration: Duration(seconds: 5),
                                  backgroundColor: Colors.red,
                                  action: SnackBarAction(
                                    label: 'Close',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                    },
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackbar);
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Row(children: [
                      Checkbox(
                        value: _showPassword,
                        onChanged: (value) {
                          setState(() {
                            _showPassword = value!;
                          });
                        },
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.004),
                      Text(
                        "Show Password",
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.011),
                      ),
                    ]),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}
