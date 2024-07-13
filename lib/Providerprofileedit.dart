import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:servtol/util/uihelper.dart'; // Ensure this path is correct and uihelper is implemented properly.

class EditProfileScreen extends StatefulWidget {
  final String fname;
  final String lname;
  final String cnic;
  final String mobile;
  final String username;
  final String email;

  EditProfileScreen({
    Key? key,
    required this.email,
    required this.cnic,
    required this.fname,
    required this.lname,
    required this.username,
    required this.mobile,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  File? _image;
  bool _isLoading = false;

  FormBuilderTextField _buildTextFormField(
      String name, String label, String initialValue, String? Function(String?)? validator) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(labelText: label),
      initialValue: initialValue,
      validator: validator,
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> saveProfileChanges() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    bool confirm = await _showConfirmationDialog(context);
    if (!confirm) return; // If user does not confirm, return early

    setState(() => _isLoading = true);
    try {
      String imageUrl = _image != null ? await _uploadImageToFirebaseStorage() : '';
      await _updateUserProfile(imageUrl);
      Fluttertoast.showToast(msg: 'Profile Updated Successfully');
      Navigator.pop(context); // Navigating back to the previous screen
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating profile: $e');
      print('Error updating profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadImageToFirebaseStorage() async {
    if (_image != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child('images/profile/$fileName.jpg');
      UploadTask uploadTask = reference.putFile(_image!);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      return await storageTaskSnapshot.ref.getDownloadURL();
    } else {
      return '';
    }
  }


  Future<void> _updateUserProfile(String imageUrl) async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      Fluttertoast.showToast(msg: "No authenticated user email found.");
      return;
    }

    // Use a document ID derived from the email
    String documentId = email.replaceAll('.', ','); // Adjust as needed if you are using such transformations

    DocumentReference userDocRef = FirebaseFirestore.instance.collection('provider').doc(documentId);

    // Prepare user data for updating or creating
    Map<String, dynamic> userData = {
      'FirstName': _formKey.currentState?.fields['FirstName']?.value,
      'LastName': _formKey.currentState?.fields['LastName']?.value,
      'Mobile': _formKey.currentState?.fields['Mobile']?.value,
      'CNIC': _formKey.currentState?.fields['CNIC']?.value,
      'ProfilePic': imageUrl.isNotEmpty ? imageUrl : null,
      'Username': _formKey.currentState?.fields['Username']?.value,
        // Make sure to include the email if creating a new document
    };

    // Debugging: print the email to check correctness
    print("Attempting to update or create profile for email: $email");

    try {
      DocumentSnapshot userDoc = await userDocRef.get();
      if (userDoc.exists) {
        await userDocRef.update(userData);
        Fluttertoast.showToast(msg: "Profile updated successfully.");
      } else {
        // Create the document if it does not exist
        await userDocRef.set(userData);
        Fluttertoast.showToast(msg: "Profile created successfully.");
      }
    } catch (e) {
      print("Failed to update or create user profile: $e");
      Fluttertoast.showToast(msg: "Failed to update or create profile: $e");
    }
  }
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Update'),
          content: const Text('Are you sure you want to update your profile?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false; // Returning false if showDialog returns null
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.grey,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: Icon(Icons.person, size: 60, color: Colors.blue[200])),
                ),
                SizedBox(height: 20),
                _buildTextFormField(
                  'FirstName',
                  'First Name',
                  widget.fname,
                      (value) => value?.isEmpty ?? true ? 'First Name cannot be empty' : null,
                ),
                _buildTextFormField(
                  'LastName',
                  'Last Name',
                  widget.lname,
                      (value) => value?.isEmpty ?? true ? 'Last Name cannot be empty' : null,
                ),
                _buildTextFormField(
                  'Username',
                  'Username',
                  widget.username,
                      (value) => value?.isEmpty ?? true ? 'Username cannot be empty' : null,
                ),
                _buildTextFormField(
                  'Mobile',
                  'Mobile',
                  widget.mobile,
                      (value) => value?.isEmpty ?? true ? 'Mobile cannot be empty' : null,
                ),
                _buildTextFormField(
                  'CNIC',
                  'CNIC',
                  widget.cnic,
                      (value) => value?.isEmpty ?? true ? 'CNIC cannot be empty' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saveProfileChanges,
                  child: Text('Save Changes', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                ),
                SizedBox(height: 15),
                if (_isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
