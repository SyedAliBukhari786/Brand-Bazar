import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:universal_html/html.dart' as html;
import 'package:firebase_storage/firebase_storage.dart';

import 'frontPage.dart';

class Orderr extends StatefulWidget {
  const Orderr({Key? key}) : super(key: key);

  @override
  _OrderrState createState() => _OrderrState();
}

class _OrderrState extends State<Orderr> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String UserID = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController _number = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _percent = TextEditingController();
  String BrandName = '';
  String? selectedStatus;
  String? selectedCategory;
  String? type;
  html.File? boo2;
  String _fileUrl = '';
  String itemNumber = '';
  String status = '';
  String imageUrl1 = '';
  String price1 = '';
  String Category1 = '';
  String Type1 = '';
  String Status1 = '';
  String ItemDesc1 = '';
  Future<void> _uploadToFirebase(html.File file) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('/${file.name}');
    await ref.putBlob(file);

    final url = await ref.getDownloadURL();

    setState(() {
      _fileUrl = url;
    });
  }

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
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('Brands')
                  .doc(UserID)
                  .get(),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error = ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                Map<String, dynamic> data = snapshot.data!.data()!;
                BrandName = data['Name'];
                return Text(BrandName,
                    style: TextStyle(
                      fontFamily: 'TitilliumWeb',
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.016,
                      color: Color(0xFF082c50),
                    ));
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            GestureDetector(
              onTap: () {},
              child: Image.asset('assets/user.png',
                  fit: BoxFit.contain,
                  color: Colors.blueGrey,
                  height: MediaQuery.of(context).size.height * 0.04),
            ),
            TextButton(
              onPressed: () async {
                await auth.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FrontPage()),
                );
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: MediaQuery.of(context).size.width * 0.011,
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          ]),
        ],
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.black),
        children: [
          SpeedDialChild(
            child: Icon(Icons.add_circle),
            label: 'Add Category',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: AlertDialog(
                      title: Text(
                        "Add in your Inventory",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.013,
                          color: Colors.grey[800],
                        ),
                      ),
                      content: Column(children: [
                        DropdownButtonFormField<String>(
                          value: type, // Set the selected category value
                          onChanged: (newValue) {
                            setState(() {
                              type = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Type',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Men',
                              child: Text('Men'),
                            ),
                            DropdownMenuItem(
                              value: 'Women',
                              child: Text('Women'),
                            ),
                            DropdownMenuItem(
                              value: 'Kids',
                              child: Text('Kids'),
                            ),
                            DropdownMenuItem(
                              value: 'Home',
                              child: Text('Home'),
                            ),
                          ],
                        ),
                        DropdownButtonFormField<String>(
                          value:
                              selectedCategory, // Set the selected category value
                          onChanged: (newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Shirts',
                              child: Text('Shirts'),
                            ),
                            DropdownMenuItem(
                              value: 'Pants',
                              child: Text('Pants'),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _number,
                          decoration: InputDecoration(
                            labelText: 'Item number',
                          ),
                        ),
                        TextFormField(
                          controller: _desc,
                          decoration: InputDecoration(
                            labelText: 'Item Description',
                          ),
                        ),
                        TextFormField(
                          controller: _price,
                          decoration: InputDecoration(
                            labelText: 'Item Price',
                          ),
                        ),
                        TextFormField(
                          controller: _percent,
                          decoration: InputDecoration(
                            labelText: 'Discount Percentage',
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        GestureDetector(
                          onTap: () async {
                            final input = html.FileUploadInputElement();
                            input.accept = 'image/*';
                            input.click();
                            await input.onChange.first;
                            final file = input.files!.first;
                            final SnackBar snackbar = SnackBar(
                              content: Text('Image Selected: ' + file.name),
                              duration: Duration(seconds: 5),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackbar);
                            setState(() {
                              boo2 = file;
                            });
                          },
                          child: Column(
                            children: [
                              if (boo2 == null)
                                Image.asset(
                                  'assets/Bupload.png',
                                  fit: BoxFit.contain,
                                  height: 100,
                                )
                              else
                                Image.asset(
                                  'assets/Aupload.png',
                                  fit: BoxFit.contain,
                                  height: 100,
                                ),
                              Text(
                                "Upload Item's Image",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        DropdownButtonFormField<String>(
                          value:
                              selectedStatus, // Set the selected category value
                          onChanged: (newValue) {
                            setState(() {
                              selectedStatus = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Status',
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'In Stock',
                              child: Text('In Stock'),
                            ),
                            DropdownMenuItem(
                              value: 'Out of Stock',
                              child: Text('Out of Stock'),
                            ),
                          ],
                        ),
                      ]),
                      actions: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: Text("Add"),
                                onPressed: () async {
                                  if (type == null) {
                                    final SnackBar snackBar = SnackBar(
                                        content: Text("Select Item type"),
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (selectedCategory == null) {
                                    final SnackBar snackBar = SnackBar(
                                        content: Text("Select Item Category"),
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_number.text.isEmpty) {
                                    final SnackBar snackBar = SnackBar(
                                        content: Text("Enter Item Number"),
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_desc.text.isEmpty) {
                                    final SnackBar snackbar = SnackBar(
                                        content: Text('Enter Item Desciption'),
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackbar);
                                  } else if (_price.text.isEmpty) {
                                    final SnackBar snackbar = SnackBar(
                                        content: Text('Enter Item Price'),
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackbar);
                                  } else if (_percent.text.isEmpty) {
                                    final SnackBar snackbar = SnackBar(
                                        content:
                                            Text('Enter Item Descount rate'),
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackbar);
                                  } else if (boo2 == null) {
                                    final SnackBar snackbar = SnackBar(
                                        content:
                                            Text('Please Upload Item Image'),
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackbar);
                                  }
                                  if (selectedStatus == null) {
                                    final SnackBar snackBar = SnackBar(
                                        content: Text("Select Item Status"),
                                        duration: Duration(seconds: 5));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    await _uploadToFirebase(boo2!);
                                    final ref = FirebaseFirestore.instance
                                        .collection("Inventory");
                                    final duplicateCheckSnapshot = await ref
                                        .where("ItemNo",
                                            isEqualTo: _number.text.trim())
                                        .get();

                                    if (duplicateCheckSnapshot
                                        .docs.isNotEmpty) {
                                      Navigator.of(context)
                                          .pop(); // Close the form
                                      setState(() {
                                        selectedCategory = null;
                                        selectedStatus = null;
                                        type = null;

                                        _desc.clear();
                                        _percent.clear();
                                        _price.clear();
                                        _number.clear();
                                        _fileUrl = '';
                                        boo2 = null;
                                      });
                                      // Item with the same ItemNo already exists
                                      final SnackBar snackbar = SnackBar(
                                        content: Text('Item already exists.'),
                                        duration: Duration(seconds: 5),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackbar);
                                    } else {
                                      // Item with the same ItemNo doesn't exist, add it to the database
                                      await ref.add({
                                        "Brand": UserID,
                                        "Category": selectedCategory,
                                        "Type": type,
                                        "Status": selectedStatus,
                                        "ItemNo": _number.text.trim(),
                                        "ItemDesc": _desc.text.trim(),
                                        "ItemPrice": _price.text.trim(),
                                        "Discount": _percent.text.trim(),
                                        "ItemImage": _fileUrl.trim(),
                                      }).then((_) {
                                        Navigator.of(context)
                                            .pop(); // Close the form
                                        setState(() {
                                          selectedCategory = null;
                                          selectedStatus = null;
                                          type = null;

                                          _desc.clear();
                                          _percent.clear();
                                          _price.clear();
                                          _number.clear();
                                          _fileUrl = '';
                                        });

                                        final SnackBar snackbar = SnackBar(
                                          content: Text(
                                              'Item Added in your Inventory'),
                                          duration: Duration(seconds: 5),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      }).catchError((error) {
                                        // Handle error if data insertion fails
                                        final SnackBar snackbar = SnackBar(
                                          content: Text(
                                              'Failed to add item. Please try again.'),
                                          duration: Duration(seconds: 5),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      });
                                    }
                                  }
                                },
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01),
                              TextButton(
                                child: Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    selectedCategory = null;
                                    selectedStatus = null;
                                    type = null;
                                    _desc.clear();
                                    _percent.clear();
                                    _price.clear();
                                    _number.clear();
                                    _fileUrl = '';
                                    boo2 = null;
                                  });
                                },
                              ),
                            ]),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SpeedDialChild(
              child: Icon(Icons.shopping_cart),
              label: 'Orders',
              onTap: () {
                Navigator.push(
                  this.context,
                  MaterialPageRoute(builder: (context) => Orderr()),
                );
              }),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('brandId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          // Extract the list of orders from the snapshot
          final List<QueryDocumentSnapshot<Object?>> orders =
              snapshot.data!.docs;

          return Center(
              child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (BuildContext context, int index) {
                final order = orders[index];

                // Extract data from the order document
                String cartId = order['cartId'];
                String userId = order['userId'];
                String address = order['address'];
                String paymentMethod = order['paymentMethod'];
                String paymentDetails = order['paymentDetails'];

                return ListTile(
                  leading: FutureBuilder<String>(
                    future: FirebaseFirestore.instance
                        .collection('Cart')
                        .doc(cartId)
                        .get()
                        .then((cartDoc) {
                      if (cartDoc.exists) {
                        String itemNo = cartDoc['items'];
                        return FirebaseFirestore.instance
                            .collection('Inventory')
                            .where('ItemNo', isEqualTo: itemNo)
                            .get()
                            .then((inventorySnapshot) {
                          if (inventorySnapshot.docs.isNotEmpty) {
                            String imageUrl =
                                inventorySnapshot.docs.first['ItemImage'];
                            imageUrl1 = imageUrl;

                            String price =
                                inventorySnapshot.docs.first['ItemPrice'];
                            price1 = price;
                            String Category =
                                inventorySnapshot.docs.first['Category'];
                            Category1 = Category;

                            String Type = inventorySnapshot.docs.first['Type'];
                            Type1 = Type;

                            String Status =
                                inventorySnapshot.docs.first['Status'];
                            Status1 = Status;

                            String ItemDesc =
                                inventorySnapshot.docs.first['ItemDesc'];
                            ItemDesc1 = ItemDesc;

                            return imageUrl;
                          } else {
                            return '';
                          }
                        });
                      } else {
                        return '';
                      }
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String imageUrl = snapshot.data ?? '';
                        return Image.network(imageUrl,
                            height: 400, width: 100, fit: BoxFit.fill);
                      }
                    },
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: FirebaseFirestore.instance
                            .collection('Cart')
                            .doc(cartId)
                            .get()
                            .then((cartDoc) {
                          if (cartDoc.exists) {
                            return cartDoc['items'];
                          } else {
                            return '';
                          }
                        }),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            itemNumber = snapshot.data ?? '';
                            return Text(
                              'Item Number: $itemNumber',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      ),
                      // Display Size and Price here (similar to the above)
                    ],
                  ),
                  subtitle: FutureBuilder<String>(
                    future: FirebaseFirestore.instance
                        .collection('Cart')
                        .doc(cartId)
                        .get()
                        .then((cartDoc) {
                      if (cartDoc.exists) {
                        status = cartDoc['status'];
                        return cartDoc['status'];
                      } else {
                        return '';
                      }
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        status = snapshot.data ?? '';
                        return Text('Status: $status');
                      }
                    },
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Open the dialog here with order details
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: AlertDialog(
                              title: Text('Order Details'),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    imageUrl1,
                                    height: 200,
                                    width: 300,
                                  ),
                                  Text('Item Number: $itemNumber'),
                                  // Display Size and Price here (similar to the above)
                                  Text('Status: $status'),
                                  Text('Price: $price1'),

                                  Text('Category: $Category1'),
                                  Text('Type: $Type1'),
                                  Text('Item: $Status1'),
                                  Text('Description: $ItemDesc1'),

                                  Divider(),
                                  FutureBuilder<String>(
                                    future: FirebaseFirestore.instance
                                        .collection('Customers')
                                        .doc(userId)
                                        .get()
                                        .then((userDoc) {
                                      if (userDoc.exists) {
                                        return userDoc['CName'];
                                      } else {
                                        return '';
                                      }
                                    }),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        String userName = snapshot.data ?? '';
                                        return Text('User Name: $userName');
                                      }
                                    },
                                  ),
                                  Text('Address: $address'),
                                  Text('Payment Method: $paymentMethod'),
                                  Text('Payment Details: $paymentDetails'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirm Delete'),
                                          content: Text(
                                              'Are you sure you want to permenantly delete this Order?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Delete'),
                                              onPressed: () async {
                                                // Delete the document from Firestore
                                                FirebaseFirestore.instance
                                                    .collection('Orders')
                                                    .doc(order.id)
                                                    .delete();
                                                Navigator.of(context).pop();

                                                // Show success message or perform any other action
                                                final SnackBar snackbar =
                                                    SnackBar(
                                                  content: Text(
                                                      'Item deleted successfully'),
                                                  duration:
                                                      Duration(seconds: 5),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackbar);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirm Delivery'),
                                          content: Text(
                                              'Are you sure you want to Send this item for delivery?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Deliver'),
                                              onPressed: () async {
                                                // Delete the document from Firestore
                                                FirebaseFirestore.instance
                                                    .collection('Cart')
                                                    .doc(cartId)
                                                    .update({
                                                  'status': 'delivered'
                                                });
                                                Navigator.of(context).pop();
                                                // Show success message or perform any other action
                                                final SnackBar snackbar =
                                                    SnackBar(
                                                  content: Text(
                                                      'Item Delivered successfully'),
                                                  duration:
                                                      Duration(seconds: 5),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackbar);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }, // Close the dialog

                                  child: Text('Deliver'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text('OPEN'),
                  ),
                );
              },
            ),
          ));
        },
      ),
    );
  }
}
