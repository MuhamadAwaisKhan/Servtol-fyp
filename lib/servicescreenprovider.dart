import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/ServiceScreenDetail.dart';
import 'package:servtol/addservices.dart';
import 'package:servtol/edit%20service.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class ServiceScreenWidget extends StatefulWidget {
   ServiceScreenWidget({Key? key}) : super(key: key);

  @override
  State<ServiceScreenWidget> createState() => _ServiceScreenWidgetState();
}

TextEditingController searchcontroller = TextEditingController();

class _ServiceScreenWidgetState extends State<ServiceScreenWidget> {
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
            icon: Icon(Icons.add_box_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => servicesaddition()));
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
            SizedBox(height: 15),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('service').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    return snapshot.hasData
                        ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        return Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple,
                                  Colors.deepPurple.shade200,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Card(
                              color: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                leading: doc['ImageUrl'] != null
                                    ? CircleAvatar(
                                  backgroundImage: NetworkImage(doc['ImageUrl']),
                                  radius: 25,
                                )
                                    : CircleAvatar(
                                  child: Icon(Icons.image_not_supported_rounded, size: 50),
                                ),
                                title: Text(
                                    doc['ServiceName'] ?? 'No name',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                subtitle: Text(
                                    doc['Category'] ?? 'No category',
                                    style: TextStyle(fontFamily: 'Poppins', color: Colors.white70)),
                                trailing: Text(
                                    "\$" + (doc['Price']?.toString() ?? 'No Price'),
                                    style: TextStyle(
                                        fontFamily: 'Poppins', color: Colors.amber, fontWeight: FontWeight.bold)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServiceDetailScreen(service: doc),
                                    ),
                                  );
                                },
                              ),
                            ));
                      },
                    )
                        : Text("No data available");
                }
              },
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {

      //   },
      //   label
      //   // child: Icon(Icons.add, size: 30),
      //   // backgroundColor: AppColors.black,
      //   // elevation: 5.0,
      // ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => servicesaddition()));
        },
        label: Text(
          'Add Service',
          style: TextStyle(color: AppColors.secondaryColor), // Set your text color here
        ),
        icon: Icon(
          Icons.add,
          color: AppColors.iconColor, // Set your icon color here
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }
}
