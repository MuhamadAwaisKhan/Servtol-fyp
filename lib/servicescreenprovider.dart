import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/addservices.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class ServiceScreenWidget extends StatefulWidget {
  const ServiceScreenWidget({Key? key}) : super(key: key);

  @override
  State<ServiceScreenWidget> createState() => _ServiceScreenWidgetState();
}

TextEditingController searchcontroller = TextEditingController();

class _ServiceScreenWidgetState extends State<ServiceScreenWidget> {
  Future<void> _deletedata(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('service')
          .doc(documentId)
          .delete();
      // Reset text fields after data is added

      // Show a success message or navigate to a different screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data Deleted successfully')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to Delete data: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Services",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.category_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add_box_rounded),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => servicesaddition()));
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            uihelper.CustomTextField(
                searchcontroller, "Search", Icons.search, false),
            Row(
              children: [
                Expanded(
                  child: uihelper.CustomButton(
                    () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (Context) => physicalservices()));
                    },
                    "Physical ",
                    40,
                    150,
                    // Icons.supervised_user_circle,
                    // Colors.grey, // Specify the default color of the icon
                    // isSecondButtonClicked, // Pass the clicked state to the button
                  ),
                ),
                Expanded(
                  child: uihelper.CustomButton(
                    () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         // builder: (Context) => digitalservices()));
                    },
                    "Digital ",
                    40,
                    150,
                    // Icons.contacts_sharp,
                    // Colors.grey, // Specify the default color of the icon
                    // isFirstButtonClicked, // Pass the clicked state to the button
                  ),
                ),
                Expanded(
                  child: uihelper.CustomButton(
                    () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (Context) => hybridservices()));
                    },
                    "Hybrid ",
                    40,
                    150,
                    // Icons.contacts_sharp,
                    // Colors.grey, // Specify the default color of the icon
                    // isFirstButtonClicked, // Pass the clicked state to the button
                  ),
                ),
              ],
            ),
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('service').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {

                    return Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            // Get the image URL from Firestore document
                            String ImageUrl = snapshot.data!.docs[index]["ImageUrl"];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Container(
                                  child: Row(
                                children: [
                                  Column(children: [
                                    CircleAvatar(
                                      child: ImageUrl.isNotEmpty
                                          ? Image.network(
                                        ImageUrl,
                                        // fit: BoxFit.cover,
                                      )
                                          : Icon(Icons.account_circle),
                                      radius: 60, // adjust the radius as needed
                                      // child: Icon(Icons.account_circle),
                                      // // child: Text("${index + 1}"),
                                    ),
                                  ]),
                                  Column(
                                    children: [
                                      Text("${snapshot.data!.docs[index].id}"),
                                      Text("${snapshot.data!.docs[index]["ServiceName"]}"),

                                      Text(
                                          "${snapshot.data!.docs[index]["Category"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["Subcategory"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["Province"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["City"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["Area"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["ServiceType"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["WageType"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["Price"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["Discount"]}"),
                                      // Text("${snapshot.data!.docs[index]["TimeSlot"] ?? "N/A"}"),

                                      Text(
                                          "${snapshot.data!.docs[index]["TimeSlot"]}"),
                                      Text(
                                          "${snapshot.data!.docs[index]["Description"]}"),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            _deletedata(
                                                snapshot.data!.docs[index].id);
                                          },
                                          child: Icon(Icons.delete))
                                    ],
                                  )
                                ],
                              )),

                            );

                            //   ListTile(
                            //   leading: CircleAvatar(
                            //    child: Icon(Icons.account_circle),
                            //     // child: Text("${index + 1}"),
                            //   ),
                            //   title: Center(child: Text("${snapshot.data!.docs[index]["email"]}")),
                            //    subtitle:
                            //      Column(
                            //        children: [
                            //          Text("${snapshot.data!.docs[index].id}"),
                            //          Text("${snapshot.data!.docs[index]["name"]}"),
                            //          Text("${snapshot.data!.docs[index]["mobile"]}"),
                            //
                            //        ],
                            //      ),
                            // );
                          },
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error.toString()}"),
                    );
                  }
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
