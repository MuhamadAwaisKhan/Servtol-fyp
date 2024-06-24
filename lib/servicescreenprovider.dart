import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/addservices.dart';
import 'package:servtol/edit%20service.dart';
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
      if (mounted) {  // Check if the widget is still in the widget tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data Deleted successfully')),
        );
      }
      // // Show a success message or navigate to a different screen
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Data Deleted successfully')),
      // );
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
            icon: Icon(Icons.reorder),
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
        child:
        Column(
          children: [
            uihelper.CustomTextField(
                searchcontroller, "Search", Icons.search, false),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //       uihelper.CustomButton(() {}, "Physical", 40, 120),
            //       SizedBox(width: 10),
            //       uihelper.CustomButton(() {}, "Digital", 40, 120),
            //       SizedBox(width: 10),
            //       uihelper.CustomButton(() {}, "Hybrid", 40, 120),
            //     ],
            //   ),
            // ),
            SizedBox(height: 15),
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
                            String ImageUrl =
                                snapshot.data!.docs[index]["ImageUrl"];
                            return  Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: ImageUrl.isNotEmpty
                                        ? NetworkImage(ImageUrl)
                                        : null,
                                    child: ImageUrl.isEmpty
                                        ? Icon(Icons.account_circle)
                                        : null,
                                    radius: 60, // Adjust the radius as needed
                                  ),
                                  SizedBox(width: 20),
                                  // Adjust the spacing between the image and the text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align text to the left
                                      children: [
                                        Text(
                                            "${snapshot.data!.docs[index].id}"),
                                        Text(
                                            "${snapshot.data!.docs[index]["ServiceName"]}"),
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
                                        Text(
                                            "${snapshot.data!.docs[index]["TimeSlot"]}"),
                                        Text(
                                            "${snapshot.data!.docs[index]["Description"]}"),
                                      ],
                                    ),
                                  ),

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _deletedata(
                                              snapshot.data!.docs[index].id);
                                        },
                                        child: Icon(Icons.delete),
                                      ),
                                      SizedBox(height: 15.0),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => editservice(
                                                serviceId: snapshot
                                                    .data!.docs[index].id,
                                                sericename: snapshot.data!
                                                    .docs[index]["ServiceName"],
                                                category: snapshot.data!
                                                    .docs[index]["Category"],
                                                Subcategory: snapshot.data!
                                                    .docs[index]["Subcategory"],
                                                Province: snapshot.data!
                                                    .docs[index]["Province"],
                                                City: snapshot.data!.docs[index]
                                                    ["City"],
                                                Area: snapshot.data!.docs[index]
                                                    ["Area"],
                                                ServiceType: snapshot.data!
                                                    .docs[index]["ServiceType"],
                                                WageType: snapshot.data!
                                                    .docs[index]["WageType"],
                                                Price: snapshot
                                                    .data!.docs[index]["Price"],
                                                Discount: snapshot.data!
                                                    .docs[index]["Discount"],
                                                TimeSlot: snapshot.data!
                                                    .docs[index]["TimeSlot"],
                                                Description: snapshot.data!
                                                    .docs[index]["Description"],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Icon(Icons.edit),
                                      )
                                    ],
                                  ),

                                ],
                              );
                          },
                        ),

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
