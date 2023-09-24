import 'package:brandbazaar/brandDashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'brandLogin.dart';
import 'brandSignup.dart';
import 'frontPage.dart';
import 'openCategory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDKl2Y7eiKg23wtX5HO74KKjIDT2S_8tWI",
          appId: "1:621760630536:web:9dd0150d51758fcebfe6bd",
          storageBucket: "brandbazaar-12.appspot.com",
          messagingSenderId: "621760630536",
          projectId: "brandbazaar-12"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    Widget firstWidget;

//     if (firebaseUser != null) {
//       firstWidget = BrandDashboard();
//     } else {
//       firstWidget = BrandLogin();
//     }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brand Bazaar',
      home: FrontPage(),
    );
  }
}
