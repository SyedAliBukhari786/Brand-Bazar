import 'package:brandbazaar/brandLogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BrandSignup extends StatefulWidget {
  const BrandSignup({Key? key}) : super(key: key);
  @override
  _BrandSignupState createState() => _BrandSignupState();
}

class _BrandSignupState extends State<BrandSignup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TextEditingController _Cpass = TextEditingController();

  final TextEditingController name = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  String uidd = "";

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
                "BRAND SIGNUP",
                style: TextStyle(
                  fontFamily: 'TitilliumWeb',
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.016,
                  color: Color(0xFF082c50),
                ),
              ),
            ]),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/brandSignup.png',
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.4),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(builder: (context) => BrandLogin()),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account?   ",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize:
                                MediaQuery.of(context).size.width * 0.012),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.012),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'Brand Name',
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Brand Email',
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  TextFormField(
                    controller: _Cpass,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
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
                          'Sign up',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.015,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          if (name.text.isEmpty || name.text == '') {
                            final SnackBar snackBar = SnackBar(
                              content: Text("Enter Brand Name"),
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
                          } else if (_emailController.text.isEmpty ||
                              _emailController.text == '') {
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
                          } else if (!EmailValidator.validate(
                              _emailController.text)) {
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
                          } else if (_passwordController.text.isEmpty ||
                              _passwordController.text == '') {
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
                          } else if (_Cpass.text.isEmpty || _Cpass.text == '') {
                            final SnackBar snackbar = SnackBar(
                              content: Text('Enter Confirm Password'),
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
                          } else if (_passwordController.text != _Cpass.text) {
                            final SnackBar snackbar = SnackBar(
                              content: Text('Passwords do not macth'),
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
                            setState(() {
                              _Cpass.clear();
                              _passwordController.clear();
                            });
                          } else {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text)
                                .then((authResult) async {
                              // User creation successful
                              final User? user = authResult.user;
                              if (user != null) {
                                uidd = user.uid;
                              }

                              // Insert data into Firestore
                              await FirebaseFirestore.instance
                                  .collection('Brands')
                                  .doc(uidd)
                                  .set({
                                'Name': name.text.trim(),
                              }); // Replace with your data

                              // Show success snackbar
                              final SnackBar snackbar = SnackBar(
                                content: Text('Brand Registered'),
                                duration: Duration(seconds: 5),
                                backgroundColor: Colors.green,
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

                              setState(() {
                                _Cpass.clear();
                                _emailController.clear();
                                _passwordController.clear();
                                name.clear();
                              });
                            }).catchError((e) {
                              // Handle registration error
                              print(e.toString());
                              final SnackBar snackbar = SnackBar(
                                content: Text('Some error occurred'),
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
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
