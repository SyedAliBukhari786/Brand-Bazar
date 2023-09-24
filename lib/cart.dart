import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'openItem.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Colors.black), // Set the icon color here

        backgroundColor: Colors.white,
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
        ]),
        actions: [
          Row(children: [
            Column(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              GestureDetector(
                onTap: () {},
                child: Image.asset('assets/cart.png',
                    fit: BoxFit.contain,
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.03),
              ),
              TextButton(
                onPressed: () async {},
                child: Text(
                  "Cart",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.01,
                  ),
                ),
              ),
            ]),
            SizedBox(width: MediaQuery.of(context).size.width * 0.001),
            Column(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              GestureDetector(
                onTap: () {},
                child: Image.asset('assets/FrontUser.png',
                    fit: BoxFit.contain,
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.03),
              ),
              TextButton(
                onPressed: () async {},
                child: Text(
                  "Account",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.01,
                  ),
                ),
              ),
            ]),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          ]),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
