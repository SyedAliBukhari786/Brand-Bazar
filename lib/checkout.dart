import 'package:brandbazaar/userLogin.dart';
import 'package:brandbazaar/userOrders.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'brandLogin.dart';
import 'frontPage.dart';

class CheckoutPage extends StatefulWidget {
  CheckoutPage({Key? key}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController addressController = TextEditingController();
  TextEditingController paymentDetailsController = TextEditingController();
  String itemId = '';
  String cartDocumentId = '';

  String selectedPaymentMethod = "Cash on Delivery";

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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.width * 0.03),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding:
                      EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: "Delivery Address",
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.width * 0.015),

                      // Payment Method Selection
                      Text("Select Payment Method:"),
                      DropdownButton<String>(
                        value: selectedPaymentMethod,
                        onChanged: (newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue!;
                          });
                        },
                        items: [
                          "Cash on Delivery",
                          "Easypaisa",
                          "Jazzcash",
                          "Bank Account"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      if (selectedPaymentMethod !=
                          "Cash on Delivery") // Show Payment Details
                        TextFormField(
                          controller: paymentDetailsController,
                          decoration: InputDecoration(
                              labelText: "Account Details (IBAN number)"),
                        ),
                      SizedBox(
                          height: MediaQuery.of(context).size.width * 0.015),

                      // Confirm Order Button
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.2,
                        margin: EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (addressController.text.isEmpty ||
                                addressController.text == '') {
                              final SnackBar snackBar = SnackBar(
                                content: Text("Enter Complete Address"),
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
                            } else if (selectedPaymentMethod !=
                                    "Cash on Delivery" &&
                                paymentDetailsController.text.isEmpty) {
                              final SnackBar snackBar = SnackBar(
                                content: Text("Enter Payment Details"),
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
                            } else if (paymentDetailsController.text.length >
                                    24 ||
                                paymentDetailsController.text.length < 24) {
                              final SnackBar snackBar = SnackBar(
                                content: Text("Enter correct IBAN number"),
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
                            } else {
                              // Get the current user's ID
                              String userId =
                                  FirebaseAuth.instance.currentUser!.uid;

                              // Compile the address and payment details
                              String address = addressController.text;
                              String paymentMethod = selectedPaymentMethod;
                              String paymentDetails =
                                  paymentDetailsController.text;

                              CollectionReference cartCollection =
                                  FirebaseFirestore.instance.collection('Cart');
                              QuerySnapshot<Map<String, dynamic>>
                                  cartItemsSnapshot = await cartCollection
                                          .where('User', isEqualTo: userId)
                                          .where('status', isEqualTo: 'ordered')
                                          .get()
                                      as QuerySnapshot<Map<String, dynamic>>;

                              for (QueryDocumentSnapshot<
                                      Map<String, dynamic>> cartItem
                                  in cartItemsSnapshot.docs) {
                                // Get the cart ID
                                String cartId = cartItem.id;
                                String Brand = cartItem['Brand'];
                                // Optionally, you can add more order details here based on the cart item

                                // Create a new document for each cartId in the "Orders" collection
                                await FirebaseFirestore.instance
                                    .collection('Orders')
                                    .add({
                                  'userId': userId,
                                  'cartId': cartId, // Set cartId for this order
                                  'brandId': Brand,
                                  'address': address,
                                  'paymentMethod': paymentMethod,
                                  'paymentDetails': paymentDetails,
                                }).then((orderDocRef) {
                                  // Update the status of the cart item to 'checkout'
                                  cartCollection
                                      .doc(cartId)
                                      .update({'status': 'checkout'});
                                }).catchError((error) {
                                  print("Error placing order: $error");
                                  final SnackBar snackBar = SnackBar(
                                    content: Text("Error: Order not placed"),
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

                              // Show a success message and navigate to another page
                              final SnackBar snackBar = SnackBar(
                                content: Text("Orders placed successfully"),
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
                                  .showSnackBar(snackBar);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FrontPage()),
                              );
                            }
                          },
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
                          child: Text(
                            "Confirm Order",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.015),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
