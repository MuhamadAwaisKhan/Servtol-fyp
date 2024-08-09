import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/util/AppColors.dart';

class profilecustomer extends StatefulWidget {
  const profilecustomer({super.key});

  @override
  State<profilecustomer> createState() => _profilecustomerState();
}

class _profilecustomerState extends State<profilecustomer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Profile Section"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customer')
            .doc(_auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No data available"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var docId = snapshot.data!.id;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider<Object>?
                        : data['ProfilePic'] != null
                            ? NetworkImage(data['ProfilePic'] as String)
                                as ImageProvider<Object>?
                            : null,
                    child: _image == null && data['ProfilePic'] == null
                        ? Icon(Icons.add_a_photo,
                            size: 60, color: Colors.grey[200])
                        : null,
                    backgroundColor: Colors.deepPurple[200],
                  ),
                ),
                SizedBox(height: 20),
                detailItem('First Name:', data['FirstName']),
                detailItem('Last Name:', data['LastName']),
                detailItem('Username:', data['Username']),
                detailItem('Email:', data['Email']),
                detailItem('Mobile:', data['Mobile']),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => showEditProfileDialog(data, docId),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: Text('Edit Profile',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: logout,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: Text('Logout',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          );
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          Text(value ?? 'Not provided',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void showEditProfileDialog(Map<String, dynamic> data, String docId) {
    TextEditingController firstNameController =
        TextEditingController(text: data['FirstName']);
    TextEditingController lastNameController =
        TextEditingController(text: data['LastName']);
    TextEditingController usernameController =
        TextEditingController(text: data['Username']);
    TextEditingController mobileController =
        TextEditingController(text: data['Mobile']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Profile"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        await pickImage();
                        setState(
                            () {}); // Refresh the dialog to show the selected image
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _image != null
                            ? FileImage(_image!) as ImageProvider<Object>?
                            : data['ProfilePic'] != null
                                ? NetworkImage(data['ProfilePic'] as String)
                                    as ImageProvider<Object>?
                                : null,
                        child: _image == null && data['ProfilePic'] == null
                            ? Icon(Icons.add_a_photo,
                                size: 60, color: Colors.grey[200])
                            : null,
                        backgroundColor: Colors.deepPurple[200],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                        controller: firstNameController,
                        decoration: InputDecoration(labelText: "First Name")),
                    SizedBox(height: 10),
                    TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(labelText: "Last Name")),
                    SizedBox(height: 10),
                    TextField(
                        controller: usernameController,
                        decoration: InputDecoration(labelText: "Username")),
                    SizedBox(height: 10),
                    TextField(
                        controller: mobileController,
                        decoration: InputDecoration(labelText: "Mobile")),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: _isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 10),
                            Text('Saving...'),
                          ],
                        )
                      : Text('Save', style: TextStyle(color: Colors.green)),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          String imageUrl =
                              await _uploadImageToFirebaseStorage();
                          await updateProfileData(
                              docId,
                              firstNameController.text,
                              lastNameController.text,
                              usernameController.text,
                              mobileController.text,

                              imageUrl);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebaseStorage() async {
    if (_image == null) {
      return ''; // Return empty if no image is selected
    }
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child('images/profile/$fileName.jpg');
    UploadTask uploadTask = reference.putFile(_image!);
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    return await storageTaskSnapshot.ref.getDownloadURL();
  }

  Future<void> updateProfileData(
      String docId,
      String firstName,
      String lastName,
      String username,
      String mobile,

      String imageUrl) async {
    Map<String, dynamic> dataToUpdate = {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Mobile': mobile,
      'ProfilePic': imageUrl.isNotEmpty ? imageUrl : null,
    };
    await FirebaseFirestore.instance
        .collection('customer')
        .doc(docId)
        .update(dataToUpdate)
        .then((value) => Fluttertoast.showToast(msg: "Profile Updated"))
        .catchError((error) =>
            Fluttertoast.showToast(msg: "Failed to update profile: $error"));
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => logincustomer()));
    Fluttertoast.showToast(msg: "Logged out successfully");
  }
}
