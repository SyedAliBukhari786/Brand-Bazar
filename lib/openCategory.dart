import 'package:brandbazaar/userLogin.dart';
import 'package:brandbazaar/userOrders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'brandLogin.dart';
import 'checkout.dart';
import 'frontPage.dart';
import 'openItem.dart';

class OpenCategory extends StatefulWidget {
  final String brand;
  final String category;

  const OpenCategory({required this.brand, required this.category, Key? key})
      : super(key: key);

  @override
  _OpenCategoryState createState() => _OpenCategoryState();
}

class _OpenCategoryState extends State<OpenCategory> {
  late AssetImage backgroundImage;
  String itemId = '';
  String cartDocumentId = '';

  @override
  void initState() {
    super.initState();

    // Determine the appropriate AssetImage based on widget.category
    if (widget.category == 'Shirts') {
      backgroundImage = AssetImage('assets/Bshirt.jpg');
    } else if (widget.category == 'Pants') {
      backgroundImage = AssetImage('assets/Bpant.jpg');
    } else if (widget.category == 'Shoes') {
      backgroundImage = AssetImage('assets/Bshoes.jpg');
    } else if (widget.category == 'Watches') {
      backgroundImage = AssetImage('assets/Bwatches.jpg');
    } else if (widget.category == 'Bags') {
      backgroundImage = AssetImage('assets/Bbags.jpg');
    } else if (widget.category == 'Jackets') {
      backgroundImage = AssetImage('assets/Bjackets.jpg');
    } else if (widget.category == 'Sunglasses') {
      backgroundImage = AssetImage('assets/Bsunglasses.jpg');
    } else {
      backgroundImage = AssetImage('assets/Bdefault.jpg');
    }
  }

  String? selectedDropdownValue1;
  String? selectedDropdownValue2;

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
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5), // Color of the border
                  width: 1.0, // Width of the border
                ),
              ),
              child: Row(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: backgroundImage,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                      MediaQuery.of(context).size.width * 0.04,
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
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Text(
                          widget.category,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.02,
                            fontFamily: 'TitilliumWeb',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                ),
              ]),
            ),
          ),
          Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5), // Color of the border
                    width: 1.0, // Width of the border
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Text("TYPE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.013)),
                      Flexible(
                        child: DropdownButton<String>(
                          value: selectedDropdownValue1,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDropdownValue1 = newValue;
                            });
                          },
                          items: <String>['Women', 'Men', 'Kids', 'Home']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ]),
                    Column(children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Text("STATUS",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.013)),
                      Flexible(
                        child: DropdownButton<String>(
                          value: selectedDropdownValue2,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDropdownValue2 = newValue;
                            });
                          },
                          items: <String>['In Stock', 'Out of Stock']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ]),
                    Flexible(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.1,
                        margin: EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedDropdownValue1 = null;
                              selectedDropdownValue2 = null;
                            });
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(fontSize: 20, color: Colors.black),
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
                  ],
                )),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.977,
              height: MediaQuery.of(context).size.height,
              child: StreamBuilder<QuerySnapshot>(
                  stream: buildQuery(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Transform.scale(
                          scale: 0.1, child: CircularProgressIndicator());
                    }

                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    if (documents.isEmpty) {
                      return Text('No such Item Exits');
                    }
                    return GridView.builder(
                        itemCount: documents.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final DocumentSnapshot document = documents[index];

                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OpenedItem(
                                      documentId: document.id,
                                      brand: document['Brand'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.all(20),
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                width: MediaQuery.of(context).size.width * 0.1,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(document['ItemImage']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFf5f5f7),
                                        ),
                                        width: double.infinity,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    FutureBuilder<
                                                        DocumentSnapshot<
                                                            Map<String,
                                                                dynamic>>>(
                                                      future: FirebaseFirestore
                                                          .instance
                                                          .collection('Brands')
                                                          .doc(widget.brand)
                                                          .get(),
                                                      builder: (context,
                                                          brandSnapshot) {
                                                        if (brandSnapshot
                                                            .hasData) {
                                                          return Text(
                                                            "   " +
                                                                brandSnapshot
                                                                        .data![
                                                                    'Name'],
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.011,
                                                              fontFamily:
                                                                  'TitilliumWeb',
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          );
                                                        } else {
                                                          return Text(
                                                              'Loading...');
                                                        }
                                                      },
                                                    ),
                                                    Text(
                                                      "  - " +
                                                          document['Category'],
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.011,
                                                          color: Colors.black),
                                                      textAlign:
                                                          TextAlign.justify,
                                                    ),
                                                  ]),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "  Description:  ",
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.011,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          document['ItemDesc'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.011,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "  Status:  ",
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.011,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: document['Status'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.011,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "  Price:  ",
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.011,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: document[
                                                            'ItemPrice'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.011,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "  with  ",
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.011,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: document[
                                                            'Discount'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.0115,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: "  Discount",
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.011,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                            ]),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ),
        ]),
      ),
    );
  }

  Stream<QuerySnapshot> buildQuery() {
    Query query = FirebaseFirestore.instance.collection('Inventory');

    // Apply the Category filter
    query = query
        .where('Category', isEqualTo: widget.category)
        .where('Brand', isEqualTo: widget.brand);

    // Apply filters based on selected dropdown values
    if (selectedDropdownValue1 != null && selectedDropdownValue2 == null) {
      query = query.where('Type', isEqualTo: selectedDropdownValue1);
    }
    if (selectedDropdownValue2 != null && selectedDropdownValue1 == null) {
      query = query.where('Status', isEqualTo: selectedDropdownValue2);
    }
    if (selectedDropdownValue1 != null && selectedDropdownValue2 != null) {
      query = query
          .where('Type', isEqualTo: selectedDropdownValue1)
          .where('Status', isEqualTo: selectedDropdownValue2);
    }
    return query.snapshots();
  }
}
