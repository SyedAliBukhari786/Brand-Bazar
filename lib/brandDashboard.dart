import 'dart:math';
import 'package:brandbazaar/brandLogin.dart';
import 'package:brandbazaar/frontPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:universal_html/html.dart' as html;
import 'package:firebase_storage/firebase_storage.dart';

import 'order.dart';

class BrandDashboard extends StatefulWidget {
  const BrandDashboard({Key? key}) : super(key: key);
  @override
  _BrandDashboardState createState() => _BrandDashboardState();
}

class _BrandDashboardState extends State<BrandDashboard> {
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
                            DropdownMenuItem(
                              value: 'Shoes',
                              child: Text('Shoes'),
                            ),
                            DropdownMenuItem(
                              value: 'Watches',
                              child: Text('Watches'),
                            ),
                            DropdownMenuItem(
                              value: 'Bags',
                              child: Text('Bags'),
                            ),
                            DropdownMenuItem(
                              value: 'Jackets',
                              child: Text('Jackets'),
                            ),
                            DropdownMenuItem(
                              value: 'Sunglasses',
                              child: Text('Sunglasses'),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Text('Your Inventory',
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
                    .collection('Inventory')
                    .where('Brand', isEqualTo: UserID)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Transform.scale(
                        scale: 0.1, child: CircularProgressIndicator());
                  }

                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: documents.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, childAspectRatio: 1.2),
                    itemBuilder: (BuildContext context, int index) {
                      final DocumentSnapshot document = documents[index];
                      final random = Random();
                      final color = Color.fromARGB(
                        255,
                        random.nextInt(256),
                        random.nextInt(256),
                        random.nextInt(256),
                      );

                      return Container(
                        margin: EdgeInsets.all(20),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: color,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 20, right: 10),
                                child: Image.network(
                                  document['ItemImage'],
                                  fit: BoxFit.contain,
                                  height: 100,
                                  width:
                                      MediaQuery.of(context).size.width * 0.12,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Item Number: " + document['ItemNo'] + " ",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.013,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.005),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(0xFFf5f5f7),
                                ),
                                width: double.infinity,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirm Delete'),
                                                  content: Text(
                                                      'Are you sure you want to permenantly delete this item from your inventory?'),
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
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Inventory')
                                                            .doc(document
                                                                .id) // Replace with the document ID
                                                            .delete();

                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog

                                                        // Show success message or perform any other action
                                                        final SnackBar
                                                            snackbar = SnackBar(
                                                          content: Text(
                                                              'Item deleted successfully'),
                                                          duration: Duration(
                                                              seconds: 5),
                                                        );
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                snackbar);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.011,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      spreadRadius: 3,
                                                      blurRadius: 5,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.5,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.5,
                                                ),
                                                child: AlertDialog(
                                                  title: Text(
                                                    "Item Info",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.013,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          Center(
                                                              child:
                                                                  Image.network(
                                                            document[
                                                                'ItemImage'],
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.3,
                                                            fit: BoxFit.cover,
                                                          )),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            child: Text(
                                                              'Item Number: ' +
                                                                  document[
                                                                      'ItemNo'],
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            child: Text(
                                                              'Item Category: ' +
                                                                  document[
                                                                      'Category'],
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            child: Text(
                                                              'Item Type: ' +
                                                                  document[
                                                                      'Type'],
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            child: Text(
                                                              'Item Description: ' +
                                                                  document[
                                                                      'ItemDesc'],
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            child: Text(
                                                              'Item Status: ' +
                                                                  document[
                                                                      'Status'],
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            child: Text(
                                                              'Item Price: ' +
                                                                  document[
                                                                      'ItemPrice'],
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            child: Text(
                                                              'Discount Rate: ' +
                                                                  document[
                                                                      'Discount'],
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Divider(),
                                                        ]),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text("Close"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "  Details  ",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.011,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }),
          ),
        ]),
      ),
    );
  }
}
