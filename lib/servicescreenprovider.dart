import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/ServiceScreenDetail.dart';
import 'package:servtol/addservices.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceScreenWidget extends StatefulWidget {
  Function onBackPress;

  ServiceScreenWidget({super.key, required this.onBackPress});

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
            color: AppColors.customButton,
            icon: FaIcon(FontAwesomeIcons.circlePlus),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ServicesAddition()));
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body:  Column(
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
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild with every change
                },
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: (searchController.text.isEmpty)
                  ? FirebaseFirestore.instance
                  .collection('service')
                  .orderBy("ServiceName", descending: false)
                  .where('providerId', isEqualTo: currentUser?.uid)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection('service')
                  .where('providerId', isEqualTo: currentUser?.uid)
                  .where('serviceNameLower', // Search only on the lowercase field
                  isGreaterThanOrEqualTo: searchController.text.toLowerCase())
                  .where('serviceNameLower',
                  isLessThanOrEqualTo: searchController.text.toLowerCase() + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Blue loader

                  );
                }
                final data = snapshot.requireData;
                return Expanded( // Wrap ListView.builder with Expanded
                    child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.docs.length,
                    itemBuilder: (context, index) {
                    var doc = data.docs[index];
                    String category = doc['Category'] ?? 'No category';
                    String lottieAnimationPath;
                    switch (category) {
                      case 'Online Services':
                        lottieAnimationPath = 'assets/images/onlineservice.json';
                        break;
                      case 'Development':
                        lottieAnimationPath = 'assets/images/development.json';
                        break;
                      case 'Healthcare':
                        lottieAnimationPath = 'assets/images/healthcare.json';
                        break;
                      case 'Design & Multimedia':
                        lottieAnimationPath = 'assets/images/designmulti.json';
                        break;
                      case 'Telemedicine':
                        lottieAnimationPath = 'assets/images/Telemedicine.json';
                        break;
                      case 'Education':
                        lottieAnimationPath = 'assets/images/education.json';
                        break;
                      case 'Retail':
                        lottieAnimationPath = 'assets/images/Retail.json';
                        break;
                      case 'Online Consultation':
                        lottieAnimationPath = 'assets/images/Online Consultation.json';
                        break;
                      case 'Digital Marketing':
                        lottieAnimationPath = 'assets/images/Digital Marketing.json';
                        break;
                      case 'Online Training':
                        lottieAnimationPath = 'assets/images/onlineservice.json';
                        break;
                      case 'Event Management':
                        lottieAnimationPath = 'assets/images/Event Management.json';
                        break;
                      case 'Video Editing':
                        lottieAnimationPath = 'assets/images/Graphic Design.json';
                        break;
                      case 'Home & Maintenance ':
                        lottieAnimationPath = 'assets/images/Home & Maintenance.json';
                        break;
                      case 'Hospitality':
                        lottieAnimationPath = 'assets/images/Hospitality.json';
                        break;
                      case 'Social Media Management':
                        lottieAnimationPath = 'assets/images/Social Media Management.json';
                        break;
                      case 'IT Support':
                        lottieAnimationPath = 'assets/images/IT Support.json';
                        break;
                      case 'Personal & Lifestyle ':
                        lottieAnimationPath = 'assets/images/Personal & Lifestyle.json';
                        break;
                      case 'Graphic Design':
                        lottieAnimationPath = 'assets/images/Graphic Design.json';
                        break;
                      case 'Finance':
                        lottieAnimationPath = 'assets/images/Finance.json';
                        break;
                      default:
                        lottieAnimationPath = 'assets/images/default.json';
                    }

                    return Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.blueAccent.shade200,
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
                      child:ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        leading: Lottie.asset(
                          lottieAnimationPath,
                          height: 80,
                          width: 80,
                          fit: BoxFit.fill,
                        ),
                        title: Text(doc['ServiceName'] ?? 'No name',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white)),
                        subtitle: Text(doc['Category'] ?? 'No category',
                            style: TextStyle(
                                fontFamily: 'Poppins', color: Colors.white70,
                            fontSize: 14,
                            )),
                        trailing:Text(
                          "\u20A8${(doc['Price']?.toString() ?? 'No Price')}", // Corrected Unicode character
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceDetailScreen(service: doc),
                            ),
                          );
                        },
                        // Add this to control the bottom padding of the ListTile
                        // visualDensity: VisualDensity(vertical: -4), // Adjust the value as needed

                      ),

                    );

                  },
                      padding: EdgeInsets.only(bottom: 10), // Adjust the value as needed

                    ),

                );


              },


            ),

          ],
        ),


      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 68.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ServicesAddition()));
          },
          label: Text(
            'Add Service',
            style: TextStyle(color: Colors.white,fontFamily: "Poppins"), // Set your text color here
          ),
          icon: Icon(
            FontAwesomeIcons.add,
            color: AppColors.background, // Set your icon color here
          ),
          backgroundColor: AppColors.customButton,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
