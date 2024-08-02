import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/ServiceScreenDetail.dart';
import 'package:servtol/addservices.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceScreenWidget extends StatefulWidget {
  ServiceScreenWidget({Key? key}) : super(key: key);

  @override
  State<ServiceScreenWidget> createState() => _ServiceScreenWidgetState();
}

class _ServiceScreenWidgetState extends State<ServiceScreenWidget> {
  TextEditingController searchController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

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
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Search Services',
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: searchController.text.isNotEmpty
                      ? GestureDetector(
                    child: Icon(Icons.clear, color: Colors.grey),
                    onTap: () {
                      searchController.clear();
                      setState(() {}); // Refresh the search
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild with every change
                },
              ),
            ),
            SizedBox(height: 15),
            StreamBuilder<QuerySnapshot>(
              stream: (searchController.text.isEmpty)
                  ? FirebaseFirestore.instance
                  .collection('service')
                  .where('providerId', isEqualTo: currentUser?.uid)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection('service')
                  .where('providerId', isEqualTo: currentUser?.uid)
                  .where('ServiceName', isGreaterThanOrEqualTo: searchController.text)
                  .where('ServiceName', isLessThanOrEqualTo: searchController.text + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                final data = snapshot.requireData;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    var doc = data.docs[index];
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
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => servicesaddition()));
        },
        label: Text(
          'Add Service',
          style: TextStyle(color: Colors.white), // Set your text color here
        ),
        icon: Icon(
          Icons.add,
          color: AppColors.secondaryColor, // Set your icon color here
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
