import 'dart:math';

import 'package:brandbazaar/userLogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'brandLogin.dart';
import 'checkout.dart';
import 'frontPage.dart';

class UserOrders extends StatefulWidget {
  const UserOrders({Key? key}) : super(key: key);

  @override
  _UserOrdersState createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  String itemId = '';
  String cartDocumentId = '';
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
                onTap: () async {
                  if (FirebaseAuth.instance.currentUser == null) {
                    // User is not logged in, navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserLogin()),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.7,
                              maxWidth: MediaQuery.of(context).size.width * 0.3,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppBar(
                                    backgroundColor: Colors.deepOrange,
                                    title: Text("Cart"),
                                    automaticallyImplyLeading: false,
                                    actions: [
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Close the dialog
                                        },
                                      ),
                                    ],
                                  ),
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('Cart')
                                        .where('User',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .where('status', isEqualTo: 'ordered')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return CircularProgressIndicator();
                                      }

                                      QuerySnapshot<Map<String, dynamic>>
                                          userCartQuerySnapshot = snapshot.data
                                              as QuerySnapshot<
                                                  Map<String, dynamic>>;

                                      if (userCartQuerySnapshot.docs.isEmpty) {
                                        return Text("Cart is empty");
                                      }
                                      final List<DocumentSnapshot> documents =
                                          snapshot.data!.docs;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: documents.length,
                                        itemBuilder: (context, index) {
                                          final DocumentSnapshot document =
                                              documents[index];
                                          cartDocumentId = document.id;
                                          // Get item number from the current document
                                          String itemNo = document['items'];

                                          // Fetch additional data using FutureBuilder
                                          return FutureBuilder<QuerySnapshot>(
                                            future: FirebaseFirestore.instance
                                                .collection('Inventory')
                                                .where('ItemNo',
                                                    isEqualTo: itemNo)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return CircularProgressIndicator();
                                              }

                                              QuerySnapshot inventoryDocs =
                                                  snapshot.data!;

                                              if (inventoryDocs.docs.isEmpty) {
                                                return Text(
                                                    'Item not found in Inventory');
                                              }

                                              // Assuming there's only one document matching the query, you can access it like this:
                                              DocumentSnapshot inventoryDoc =
                                                  inventoryDocs.docs.first;

                                              // Extract data from the Inventory document
                                              String imageUrl =
                                                  inventoryDoc['ItemImage'];
                                              String category =
                                                  inventoryDoc['Category'];
                                              String itemPrice =
                                                  inventoryDoc['ItemPrice'];

                                              // Use another FutureBuilder to get Brand Name
                                              return FutureBuilder<
                                                  DocumentSnapshot>(
                                                future: FirebaseFirestore
                                                    .instance
                                                    .collection('Brands')
                                                    .doc(document['Brand'])
                                                    .get(),
                                                builder:
                                                    (context, brandSnapshot) {
                                                  if (!brandSnapshot.hasData) {
                                                    return CircularProgressIndicator();
                                                  }

                                                  DocumentSnapshot brandDoc =
                                                      brandSnapshot.data!;

                                                  // Extract Brand Name
                                                  String brandName =
                                                      brandDoc['Name'];

                                                  // Extract Size from the current Cart document
                                                  String size =
                                                      document['size'];

                                                  // Create a custom widget to display the item's information
                                                  return ListTile(
                                                    leading: Image.network(
                                                        imageUrl,
                                                        height: 200,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                        fit: BoxFit.cover),
                                                    title: Text(brandName),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text("Size: $size"),
                                                        Text(
                                                            "Category: $category"),
                                                        Text(
                                                            "Price: $itemPrice",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                    trailing: IconButton(
                                                      icon: Icon(Icons.close),
                                                      onPressed: () {
                                                        // Add the logic here to delete the item from the Cart
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('Cart')
                                                            .doc(document.id)
                                                            .delete()
                                                            .then((value) {
                                                          // Item deleted successfully
                                                          // You can show a confirmation message or update the UI
                                                        }).catchError((error) {
                                                          // Handle any errors that occur during deletion
                                                          print(
                                                              "Error deleting item: $error");
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    margin: EdgeInsets.all(5),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CheckoutPage()),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.deepOrange),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Checkout",
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.015),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
                child: Image.asset('assets/cart.png',
                    fit: BoxFit.contain,
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.03),
              ),
              TextButton(
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    // User is not logged in, navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserLogin()),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.7,
                              maxWidth: MediaQuery.of(context).size.width * 0.3,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppBar(
                                    backgroundColor: Colors.deepOrange,
                                    title: Text("Cart"),
                                    automaticallyImplyLeading: false,
                                    actions: [
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Close the dialog
                                        },
                                      ),
                                    ],
                                  ),
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('Cart')
                                        .where('User',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .where('status', isEqualTo: 'ordered')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return CircularProgressIndicator();
                                      }

                                      QuerySnapshot<Map<String, dynamic>>
                                          userCartQuerySnapshot = snapshot.data
                                              as QuerySnapshot<
                                                  Map<String, dynamic>>;

                                      if (userCartQuerySnapshot.docs.isEmpty) {
                                        return Text("Cart is empty");
                                      }
                                      final List<DocumentSnapshot> documents =
                                          snapshot.data!.docs;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: documents.length,
                                        itemBuilder: (context, index) {
                                          final DocumentSnapshot document =
                                              documents[index];
                                          cartDocumentId = document.id;
                                          // Get item number from the current document
                                          String itemNo = document['items'];

                                          // Fetch additional data using FutureBuilder
                                          return FutureBuilder<QuerySnapshot>(
                                            future: FirebaseFirestore.instance
                                                .collection('Inventory')
                                                .where('ItemNo',
                                                    isEqualTo: itemNo)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return CircularProgressIndicator();
                                              }

                                              QuerySnapshot inventoryDocs =
                                                  snapshot.data!;

                                              if (inventoryDocs.docs.isEmpty) {
                                                return Text(
                                                    'Item not found in Inventory');
                                              }

                                              // Assuming there's only one document matching the query, you can access it like this:
                                              DocumentSnapshot inventoryDoc =
                                                  inventoryDocs.docs.first;

                                              // Extract data from the Inventory document
                                              String imageUrl =
                                                  inventoryDoc['ItemImage'];
                                              String category =
                                                  inventoryDoc['Category'];
                                              String itemPrice =
                                                  inventoryDoc['ItemPrice'];

                                              // Use another FutureBuilder to get Brand Name
                                              return FutureBuilder<
                                                  DocumentSnapshot>(
                                                future: FirebaseFirestore
                                                    .instance
                                                    .collection('Brands')
                                                    .doc(document['Brand'])
                                                    .get(),
                                                builder:
                                                    (context, brandSnapshot) {
                                                  if (!brandSnapshot.hasData) {
                                                    return CircularProgressIndicator();
                                                  }

                                                  DocumentSnapshot brandDoc =
                                                      brandSnapshot.data!;

                                                  // Extract Brand Name
                                                  String brandName =
                                                      brandDoc['Name'];

                                                  // Extract Size from the current Cart document
                                                  String size =
                                                      document['size'];

                                                  // Create a custom widget to display the item's information
                                                  return ListTile(
                                                    leading: Image.network(
                                                        imageUrl,
                                                        height: 200,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                        fit: BoxFit.cover),
                                                    title: Text(brandName),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text("Size: $size"),
                                                        Text(
                                                            "Category: $category"),
                                                        Text(
                                                            "Price: $itemPrice",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                    trailing: IconButton(
                                                      icon: Icon(Icons.close),
                                                      onPressed: () {
                                                        // Add the logic here to delete the item from the Cart
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('Cart')
                                                            .doc(document.id)
                                                            .delete()
                                                            .then((value) {
                                                          // Item deleted successfully
                                                          // You can show a confirmation message or update the UI
                                                        }).catchError((error) {
                                                          // Handle any errors that occur during deletion
                                                          print(
                                                              "Error deleting item: $error");
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    margin: EdgeInsets.all(5),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CheckoutPage()),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.deepOrange),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Checkout",
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.015),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
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
                onTap: () async {
                  if (FirebaseAuth.instance.currentUser == null) {
                    // User is not logged in, navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserLogin()),
                    );
                  } else {
                    // User is logged in, log them out
                    await FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FrontPage()),
                    );
                  }
                },
                child: Image.asset('assets/FrontUser.png',
                    fit: BoxFit.contain,
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.03),
              ),
              TextButton(
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser == null) {
                    // User is not logged in, navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserLogin()),
                    );
                  } else {
                    // User is logged in, log them out
                    await FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FrontPage()),
                    );
                  }
                },
                child: Text(
                  "Logout",
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
                onTap: () async {
                  if (FirebaseAuth.instance.currentUser == null) {
                    // User is not logged in, navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserLogin()),
                    );
                  } else {
                    // User is logged in, log them out
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserOrders()),
                    );
                  }
                },
                child: Image.asset('assets/ITEMS.png',
                    fit: BoxFit.contain,
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.03),
              ),
              TextButton(
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser == null) {
                    // User is not logged in, navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserLogin()),
                    );
                  } else {
                    // User is logged in, log them out
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserOrders()),
                    );
                  }
                },
                child: Text(
                  "Items",
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
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BrandLogin()),
                  );
                },
                child: Image.asset('assets/shoes.png',
                    fit: BoxFit.contain,
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.03),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BrandLogin()),
                  );
                },
                child: Text(
                  "Brand",
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
        child: Column(children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Text('Your Orders',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.03,
                color: Color(0xFF082c50),
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Cart')
                    .where('User',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  QuerySnapshot<Map<String, dynamic>> userCartQuerySnapshot =
                      snapshot.data as QuerySnapshot<Map<String, dynamic>>;

                  if (userCartQuerySnapshot.docs.isEmpty) {
                    return Text("No Previous or pending orders.");
                  }

                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return GridView.builder(
                      itemCount: documents.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot document = documents[index];
                        cartDocumentId = document.id;

                        // Get item number from the current document
                        String itemNo = document['items'];
                        String itemStatus = document['status'];
                        return FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Inventory')
                                .where('ItemNo', isEqualTo: itemNo)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }

                              QuerySnapshot inventoryDocs = snapshot.data!;

                              if (inventoryDocs.docs.isEmpty) {
                                return Text('Item not found in Inventory');
                              }

                              // Now you need to iterate through the inventoryDocs
                              // and create a separate widget for each item
                              List<Widget> itemWidgets = [];

                              inventoryDocs.docs.forEach((inventoryDoc) {
                                // Verify field names and add error handling
                                try {
                                  // Extract data from the Inventory document
                                  String imageUrl = inventoryDoc['ItemImage'];
                                  String itemNo = inventoryDoc['ItemNo'];
                                  String itemPrice = inventoryDoc['ItemPrice'];

                                  // Use another FutureBuilder to get Brand Name
                                  var brandFuture = FirebaseFirestore.instance
                                      .collection('Brands')
                                      .doc(document['Brand'])
                                      .get();

                                  itemWidgets.add(FutureBuilder<
                                          DocumentSnapshot>(
                                      future: brandFuture,
                                      builder: (context, brandSnapshot) {
                                        if (!brandSnapshot.hasData) {
                                          return CircularProgressIndicator();
                                        }

                                        DocumentSnapshot brandDoc =
                                            brandSnapshot.data!;

                                        // Extract Brand Name
                                        String brandName = brandDoc['Name'];

                                        final random = Random();
                                        final color = Color.fromARGB(
                                          255,
                                          random.nextInt(256),
                                          random.nextInt(256),
                                          random.nextInt(256),
                                        );

                                        // Create a container or widget for the item and return it
                                        return Container(
                                          margin: EdgeInsets.all(20),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: color,
                                          ),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10,
                                                      bottom: 10,
                                                      left: 20,
                                                      right: 10),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.contain,
                                                    height: 200,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  brandName +
                                                      " Item: " +
                                                      itemNo +
                                                      " ",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.013,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.005),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.07,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Color(0xFFf5f5f7),
                                                  ),
                                                  width: double.infinity,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Text(
                                                          "Rs " +
                                                              itemPrice +
                                                              "/-",
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.011,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                        Text(
                                                          'Status: ' +
                                                              itemStatus,
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.011,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                      ]),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }));
                                } catch (e) {
                                  print(
                                      'Error processing inventory document: $e');
                                }
                              });
                              return Column(
                                children: itemWidgets,
                              );
                            });
                      });
                }),
          ),
        ]),
      ),
    );
  }
}
