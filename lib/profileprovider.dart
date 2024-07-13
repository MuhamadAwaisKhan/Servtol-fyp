import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:servtol/Providerprofileedit.dart';
import 'package:servtol/loginprovider.dart';

class ProfileScreenWidget extends StatefulWidget {
  ProfileScreenWidget({Key? key}) : super(key: key);

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        // Rich deep purple color for the header
        title: Text("Profile Section",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
      ),
      backgroundColor: Colors.grey[100], // Light grey background for body
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('provider')
            .where('Email', isEqualTo: _auth.currentUser?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text("No data available");
              }
              var doc = snapshot.data!.docs[0].data() as Map<String, dynamic>;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: doc['ProfilePic'] != null
                          ? NetworkImage(doc['ProfilePic'])
                          : null,
                      child: doc['ProfilePic'] == null
                          ? Icon(Icons.person,
                              size: 60, color: Colors.grey[200])
                          : null,
                      backgroundColor:
                          Colors.deepPurple[200], // Light purple if no image
                    ),
                    SizedBox(height: 20),
                    detailItem('First Name:', doc['FirstName']),
                    detailItem('Last Name:', doc['LastName']),
                    detailItem('Username:', doc['Username']),
                    detailItem('Email:', doc['Email']),
                    detailItem('Mobile:', doc['Mobile']),
                    detailItem('CNIC:', doc['CNIC']),
                    SizedBox(height: 30),
          ElevatedButton(
          onPressed: () {
          if (snapshot.hasData && !snapshot.data!.docs.isEmpty) {
          var doc = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => EditProfileScreen(
          email: doc['Email'] ?? '',  // Ensure fields match those in your Firestore
          cnic: doc['CNIC'] ?? '',
          fname: doc['FirstName'] ?? '',
          lname: doc['LastName'] ?? '',
          username: doc['Username'] ?? '',
          mobile: doc['Mobile'] ?? '',
          )));
          } else {
          Fluttertoast.showToast(msg: "No data available for editing.");
          }
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
          child: Text('Edit Profile', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),


          SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: logout,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15)),
                      child: Text('Logout',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ]
                ),
              );
          }
        },
      ),
    );
  }

  Widget detailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          Text(value ?? 'Not provided',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey[600])),
        ],
      ),
    );
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              loginprovider()), // Adjust this to match your app's navigation structure
    );
    Fluttertoast.showToast(msg: "Logged out successfully");
  }
}
