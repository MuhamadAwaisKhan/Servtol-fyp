import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/util/AppColors.dart';

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = ''; // The current search query

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text; // Update the search query as the user types
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Services',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Search Services',
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                prefixIcon: Icon(FontAwesomeIcons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                  child: Icon(Icons.clear, color: Colors.grey),
                  onTap: () {
                    searchController.clear();
                    setState(() {}); // Refresh the search when cleared
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
          // StreamBuilder to fetch and filter services based on the search query
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('service').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No services found.'));
                }

                // Filter services by search query
                var services = snapshot.data!.docs
                    .where((doc) {
                  var serviceName = doc['ServiceName']?.toLowerCase() ?? '';
                  return serviceName.contains(searchQuery.toLowerCase()); // Filter based on search query
                })
                    .toList();

                return ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    var serviceDoc = services[index];
                    var serviceData = serviceDoc.data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.blueAccent.shade200],
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
                        leading: Lottie.asset(
                          _getLottieAnimationPath(serviceData['Category']),
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                        ),
                        title: Text(
                          serviceData['ServiceName'] ?? 'No name',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          serviceData['Category'] ?? 'No category',
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
                        ),
                        trailing: Text(
                          "\$" + (serviceData['Price']?.toString() ?? 'No Price'),
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Servicecustomerdetail(service: serviceDoc),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getLottieAnimationPath(String category) {
    switch (category) {
      case 'Online Services':
        return 'assets/images/onlineservice.json';
      case 'Development':
        return 'assets/images/development.json';
      case 'Healthcare':
        return 'assets/images/healthcare.json';
      default:
        return 'assets/images/default.json';
    }
  }
}
