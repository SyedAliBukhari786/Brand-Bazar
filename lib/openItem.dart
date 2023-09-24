import 'package:brandbazaar/userLogin.dart';
import 'package:brandbazaar/userOrders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'brandLogin.dart';
import 'checkout.dart';
import 'frontPage.dart';

class OpenedItem extends StatefulWidget {
  final String documentId;
  final String brand;

  const OpenedItem({required this.documentId, required this.brand, Key? key})
      : super(key: key);

  @override
  _OpenedItemState createState() => _OpenedItemState();
}

class _OpenedItemState extends State<OpenedItem> {
  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];
  String selectedSize = '';
  String itemId = '';
  String cartDocumentId = '';
  String imgUrl = '';
  TextEditingController _review = TextEditingController();

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
        child: Center(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('Inventory')
                    .doc(widget.documentId)
                    .get(),
                builder: (context, brandSnapshot) {
                  if (brandSnapshot.hasData) {
                    imgUrl = brandSnapshot.data!['ItemImage'];

                    return Container(
                      margin: EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: Card(
                        elevation: 4, // Adjust the elevation as needed
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Adjust the border radius as needed
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8), // Same border radius as Card
                          child: Image.network(
                            brandSnapshot.data!['ItemImage'],
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Text('Loading...');
                  }
                },
              ),
              Container(
                margin: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.1,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    margin: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: TextFormField(
                      controller: _review,
                      decoration: InputDecoration(
                        labelText: 'Add your Review',
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.08,
                      margin: EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser == null) {
                            // User is not logged in, navigate to login page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserLogin()),
                            );
                          } else {
                            FirebaseFirestore.instance
                                .collection("Reviews")
                                .add({
                              'userId': FirebaseAuth.instance.currentUser!.uid,
                              'item': widget.documentId,
                              'review': _review.text.trim()
                            }).catchError((error) {
                              print("Error adding review: $error");
                              final SnackBar snackBar = SnackBar(
                                content: Text("Error: Review not Added"),
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
                            });
                          }
                          setState(() {
                            _review.clear();
                          });
                          // Show a success message and navigate to another page
                          final SnackBar snackBar = SnackBar(
                            content: Text("Review added successfully"),
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
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: Text(
                          'Add',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepOrange),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  margin: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          Colors.grey.withOpacity(0.5), // Color of the border
                      width: 1.0, // Width of the border
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Reviews')
                        .where('item', isEqualTo: widget.documentId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.data == null) {
                        return Text("No User Reviews to Show");
                      }

                      // Extract the reviews from the snapshot
                      final List<QueryDocumentSnapshot> reviews =
                          snapshot.data!.docs;
                      if (reviews.isEmpty) {
                        return Text("No User Reviews to Show");
                      }
                      return ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final reviewDoc = reviews[index];
                          final userName = reviewDoc['userId'];
                          final review = reviewDoc['review']; // Review content
                          return ListTile(
                            leading: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('Customers')
                                  .doc(userName)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                if (userSnapshot.hasError) {
                                  return Text('Error: ${userSnapshot.error}');
                                }

                                final userName =
                                    userSnapshot.data!['CName']; // User's Name

                                return Text(userName + ": ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.013));
                              },
                            ),
                            title: Text(review,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.013)),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.08,
                  margin: EdgeInsets.all(5),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Share with'),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    String facebookUrl =
                                        'https://www.facebook.com/sharer/sharer.php?u=$imgUrl';
                                    launch(facebookUrl);
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: Image.asset(
                                    'assets/facebook.png', // Replace with your Facebook icon image path
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    String whatsappUrl =
                                        'https://wa.me/?text=$imgUrl';
                                    launch(whatsappUrl);
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: Image.asset(
                                    'assets/whatsap.png', // Replace with your WhatsApp icon image path
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.black,
                          size: MediaQuery.of(context).size.width * 0.015,
                        ),
                        Text(
                          '  Share',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.012,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.deepOrange),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            SizedBox(width: MediaQuery.of(context).size.width * 0.1),
            Container(
              height: 100000,
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('Brands')
                          .doc(widget.brand)
                          .get(),
                      builder: (context, brandSnapshot) {
                        if (brandSnapshot.hasData) {
                          return Text(
                            brandSnapshot.data!['Name'],
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontFamily: 'TitilliumWeb',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return Text('Loading...');
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Row(children: [
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('Inventory')
                            .doc(widget.documentId)
                            .get(),
                        builder: (context, brandSnapshot) {
                          if (brandSnapshot.hasData) {
                            itemId = brandSnapshot.data!['ItemNo'];

                            return RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Item Number: ",
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.015,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: brandSnapshot.data!['ItemNo'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.015,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Text('Loading...');
                          }
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('Inventory')
                            .doc(widget.documentId)
                            .get(),
                        builder: (context, brandSnapshot) {
                          if (brandSnapshot.hasData) {
                            return RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Type: ",
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.015,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: brandSnapshot.data!['Type'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.015,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Text('Loading...');
                          }
                        },
                      ),
                    ]),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Row(children: [
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('Inventory')
                            .doc(widget.documentId)
                            .get(),
                        builder: (context, brandSnapshot) {
                          if (brandSnapshot.hasData) {
                            return RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Item Price: ",
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.015,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: brandSnapshot.data!['ItemPrice'] +
                                        "/- Rs",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.02,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Text('Loading...');
                          }
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Container(
                        color: Colors.blueGrey,
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.001,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('Inventory')
                            .doc(widget.documentId)
                            .get(),
                        builder: (context, brandSnapshot) {
                          if (brandSnapshot.hasData) {
                            return RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Discount Rate: ",
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.015,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: brandSnapshot.data!['Discount'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.015,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Text('Loading...');
                          }
                        },
                      ),
                    ]),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Container(
                      color: Colors.blueGrey,
                      height: MediaQuery.of(context).size.height * 0.001,
                      width: MediaQuery.of(context).size.width * 0.35,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Text(
                      "Sizes:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.015,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: sizes.length,
                        itemBuilder: (context, index) {
                          String size = sizes[index];
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                // Handle size selection
                                setState(() {
                                  selectedSize = size;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.011,
                                ),
                                padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.011,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedSize == size
                                        ? Colors.black
                                        : Colors.black45,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  color: selectedSize == size
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    color: selectedSize == size
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.011,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Flexible(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.35,
                        margin: EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Check if the user is logged in
                            if (FirebaseAuth.instance.currentUser == null) {
                              // User is not logged in, navigate to login page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserLogin()),
                              );
                            } else if (selectedSize.isEmpty) {
                              final SnackBar snackbar = SnackBar(
                                content: Text("Select Size"),
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
                              String userId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              CollectionReference cartCollection =
                                  FirebaseFirestore.instance.collection('Cart');
                              DocumentReference newCartRef =
                                  cartCollection.doc();

                              try {
                                await newCartRef.set({
                                  'items': itemId,
                                  'size': selectedSize,
                                  'User': userId,
                                  'Brand': widget.brand,
                                  'status': 'ordered'
                                });

                                // If the set operation succeeds, show a success SnackBar
                                final snackBar = SnackBar(
                                  content: Text('Item added to cart'),
                                  duration: Duration(seconds: 5),
                                  backgroundColor: Colors.green,
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } catch (error) {
                                // If there's an error (e.g., Firebase exception), show an error SnackBar
                                final snackBar = SnackBar(
                                  content: Text(
                                      'Failed to add item to cart: $error'),
                                  duration: Duration(seconds: 5),
                                  backgroundColor: Colors.red,
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          },
                          child: Text(
                            'ADD TO CART',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.015,
                                color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.deepOrange),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Container(
                      color: Colors.blueGrey,
                      height: MediaQuery.of(context).size.height * 0.0005,
                      width: MediaQuery.of(context).size.width * 0.35,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Text(
                      "Description:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.012,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('Inventory')
                          .doc(widget.documentId)
                          .get(),
                      builder: (context, brandSnapshot) {
                        if (brandSnapshot.hasData) {
                          return Text(
                            brandSnapshot.data!['ItemDesc'],
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.011,
                              color: Colors.black,
                            ),
                          );
                        } else {
                          return Text('Loading...');
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Container(
                      color: Colors.blueGrey,
                      height: MediaQuery.of(context).size.height * 0.0005,
                      width: MediaQuery.of(context).size.width * 0.35,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Text(
                      "Material:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.012,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Outer fabric material: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.011,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: "100% cotton",
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.011,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Container(
                      color: Colors.blueGrey,
                      height: MediaQuery.of(context).size.height * 0.0005,
                      width: MediaQuery.of(context).size.width * 0.35,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Text(
                      "Care Instructions:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.012,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      "Machine wash at 30 °C, machine wash on gentle cycle",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.011,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Container(
                      color: Colors.blueGrey,
                      height: MediaQuery.of(context).size.height * 0.0005,
                      width: MediaQuery.of(context).size.width * 0.35,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Text(
                      "Delivery Time:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.012,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      "3 to 4 working days.",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.011,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      "Returns:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.012,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      "Free returns for 31 days from delivery date.",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.011,
                        color: Colors.black,
                      ),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
