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
  Function onBackPress; // Making this final and required

  profilecustomer({super.key, required this.onBackPress});

  @override
  State<profilecustomer> createState() => _profilecustomerState();
}

class _profilecustomerState extends State<profilecustomer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  File? _tempImage; // Temporary image storage
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          "Profile Section",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.blue), // Blue loader
            ))
          : buildProfileScreen(),
    );
  }

  Widget buildProfileScreen() {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customer')
            .doc(_auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.blue), // Blue loader
            ));
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _image != null
                            ? FileImage(_image!) as ImageProvider<Object>?
                            : data['ProfilePic'] != null
                                ? NetworkImage(data['ProfilePic'] as String)
                                    as ImageProvider<Object>?
                                : null,
                        backgroundColor: Colors.blueGrey[200],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            // Match the CircleAvatar background or choose another contrasting color
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white,
                                width: 2), // White border for visibility
                          ),
                          child: Icon(Icons.add,
                              color: Colors.white,
                              size: 24), // + icon for upload/change image
                        ),
                      ),
                      if (_tempImage != null) ...[
                        Positioned(
                          right: 10,
                          top: 10,
                          child: GestureDetector(
                            onTap: confirmUpload,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: GestureDetector(
                            onTap: cancelUpload,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ],
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
                      backgroundColor: AppColors.customButton,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: Text('Edit Profile',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color: Colors.white)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: logout,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: Text('Logout',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      )),
                ),
              ],
            ),
          );
        });
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
                color: Colors.lightBlue,
                fontFamily: 'Poppins',
              )),
          Text(value ?? 'Not provided',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _tempImage = File(pickedFile.path);
      });
    }
  }

  void confirmUpload() async {
    if (_tempImage != null) {
      setState(() {
        _isLoading = true; // Activate loading indicator
      });

      try {
        // Call the upload function with _tempImage as the argument
        String imageUrl = await _uploadImageToFirebaseStorage(_tempImage!);

        if (imageUrl.isNotEmpty) {
          // Update Firestore with the new image URL
          await updateProfileImageUrl(_auth.currentUser!.uid, imageUrl);
          setState(() {
            _image = _tempImage; // Make the upload permanent in the app state
            _tempImage = null; // Clear the temporary image
          });
          Fluttertoast.showToast(msg: "Image uploaded successfully");
        } else {
          Fluttertoast.showToast(msg: "Failed to upload image");
        }
      } catch (e) {
        // Handle errors in case of failure
        print('Upload failed: $e');
        Fluttertoast.showToast(msg: "Error during image upload: $e");
      } finally {
        setState(() {
          _isLoading = false; // Deactivate loading indicator
        });
      }
    }
  }

  void cancelUpload() {
    setState(() {
      _tempImage = null;
    });
  }

  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    await FirebaseFirestore.instance
        .collection('customer')
        .doc(userId)
        .update({'ProfilePic': imageUrl}).then((value) {
      Fluttertoast.showToast(msg: "Profile image updated successfully");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Failed to update image URL: $error");
      print("Failed to update image URL: $error");
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => logincustomer()));
    Fluttertoast.showToast(msg: "Logged out successfully");
  }

  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child('images/profile/$fileName.jpg');
    UploadTask uploadTask = reference.putFile(imageFile);
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    return await storageTaskSnapshot.ref.getDownloadURL();
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
              title: Text("Edit Profile",
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        await pickImage();
                        setState(
                            () {}); // Refresh the dialog to show the selected image
                      },
                      child: ListBody(
                        children: <Widget>[
                          TextField(
                              controller: firstNameController,
                              decoration:
                                  InputDecoration(labelText: "First Name")),
                          SizedBox(height: 10),
                          TextField(
                              controller: lastNameController,
                              decoration:
                                  InputDecoration(labelText: "Last Name")),
                          SizedBox(height: 10),
                          TextField(
                              controller: usernameController,
                              decoration:
                                  InputDecoration(labelText: "Username")),
                          SizedBox(height: 10),
                          TextField(
                              controller: mobileController,
                              decoration: InputDecoration(labelText: "Mobile")),
                          SizedBox(height: 10),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel',
                      style:
                          TextStyle(fontFamily: 'Poppins', color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: _isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(width: 10),
                            Text('Saving...'),
                          ],
                        )
                      : Text('Save',
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Colors.green)),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          // String imageUrl = await _uploadImageToFirebaseStorage();
                          await updateProfileData(
                            docId,
                            firstNameController.text,
                            lastNameController.text,
                            usernameController.text,
                            mobileController.text,
                          );
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

  Future<void> updateProfileData(
    String docId,
    String firstName,
    String lastName,
    String username,
    String mobile,
  ) async {
    Map<String, dynamic> dataToUpdate = {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Mobile': mobile,
    };
    await FirebaseFirestore.instance
        .collection('customer')
        .doc(docId)
        .update(dataToUpdate)
        .then((value) => Fluttertoast.showToast(msg: "Profile Updated"))
        .catchError((error) =>
            Fluttertoast.showToast(msg: "Failed to update profile: $error"));
  }
}
