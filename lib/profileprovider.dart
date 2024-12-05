import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/customerreviewsprovider.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/timeslot.dart';
import 'package:servtol/util/AppColors.dart'; // Ensure this is the correct import path.

class ProfileScreenWidget extends StatefulWidget {
  Function onBackPress;

  ProfileScreenWidget({super.key, required this.onBackPress});

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;
  File? _tempImage; // Temporary image storage

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
      floatingActionButton: GestureDetector(
        onTap: () {
          // Open the bottom sheet for reporting problems
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return const ProblemReportForm();
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                spreadRadius: 5,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(15),
          // Inner padding for a balanced look
          child: const FaIcon(
            FontAwesomeIcons.exclamationTriangle, // Font Awesome icon
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endContained, // Ensures it's at the bottom right
    );
  }

  Widget buildProfileScreen() {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('provider')
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
                detailItem('CNIC:', data['CNIC']),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerReviewByProvider(
                          providerId:
                              _auth.currentUser!.uid, // Pass the provider ID
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.customButton,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: Text('Performance Analytics',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins', // Added font family
                          color: Colors.white)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => showEditProfileDialog(data, docId),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.customButton,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: Text('Edit Profile',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins', // Added font family
                          color: Colors.white)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimeSlotScreen(
                          providerId:
                              _auth.currentUser!.uid, // Pass the provider ID
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.customButton,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: Text('Time Slot',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins', // Added font family
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
                          fontFamily: 'Poppins', // Added font family
                          color: Colors.white)),
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
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue)),
          Text(value ?? 'Not provided',
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins', // Added font family
                  color: Colors.grey[600])),
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
        _isLoading = true; // Show loading indicator during the upload
      });

      // Call the upload function with _tempImage as the argument
      String imageUrl = await _uploadImageToFirebaseStorage(_tempImage!);

      if (imageUrl.isNotEmpty) {
        // Update Firestore with the new image URL
        await updateProfileImageUrl(_auth.currentUser!.uid, imageUrl);
        setState(() {
          _image = _tempImage; // Make the upload permanent in the app state
          _tempImage = null; // Clear the temporary image
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to upload image");
      }

      setState(() {
        _isLoading = false; // Hide loading indicator once done
      });
    }
  }

  void cancelUpload() {
    setState(() {
      _tempImage = null;
    });
  }

  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    await FirebaseFirestore.instance
        .collection('provider')
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
        context, MaterialPageRoute(builder: (context) => loginprovider()));
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

  // void showEditProfileDialog(Map<String, dynamic> data, String docId) {
  //   TextEditingController firstNameController =
  //       TextEditingController(text: data['FirstName']);
  //   TextEditingController lastNameController =
  //       TextEditingController(text: data['LastName']);
  //   TextEditingController usernameController =
  //       TextEditingController(text: data['Username']);
  //   TextEditingController mobileController =
  //       TextEditingController(text: data['Mobile']);
  //   TextEditingController cnicController =
  //       TextEditingController(text: data['CNIC']);
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: Text("Edit Profile",
  //                 style: TextStyle(
  //                     fontFamily: 'Poppins',
  //                     fontWeight: FontWeight.bold)), // Added font family
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20.0),
  //             ),
  //             content: SingleChildScrollView(
  //               child: ListBody(
  //                 children: <Widget>[
  //                   GestureDetector(
  //                     onTap: () async {
  //                       await pickImage();
  //                       setState(
  //                           () {}); // Refresh the dialog to show the selected image
  //                     },
  //                     child: ListBody(
  //                       children: <Widget>[
  //                         TextField(
  //                             controller: firstNameController,
  //                             decoration:
  //                                 InputDecoration(labelText: "First Name")),
  //                         SizedBox(height: 10),
  //                         TextField(
  //                             controller: lastNameController,
  //                             decoration:
  //                                 InputDecoration(labelText: "Last Name")),
  //                         SizedBox(height: 10),
  //                         TextField(
  //                             controller: usernameController,
  //                             decoration:
  //                                 InputDecoration(labelText: "Username")),
  //                         SizedBox(height: 10),
  //                         TextField(
  //                             controller: mobileController,
  //                             decoration: InputDecoration(labelText: "Mobile")),
  //                         SizedBox(height: 10),
  //                         TextField(
  //                             controller: cnicController,
  //                             decoration: InputDecoration(labelText: "CNIC")),
  //                         SizedBox(height: 10),
  //                       ],
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: Text('Cancel',
  //                     style:
  //                         TextStyle(fontFamily: 'Poppins', color: Colors.red)),
  //                 onPressed: () => Navigator.of(context).pop(),
  //               ),
  //               TextButton(
  //                 child: _isLoading
  //                     ? Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           CircularProgressIndicator(
  //                             valueColor: AlwaysStoppedAnimation<Color>(
  //                                 Colors.blue), // Blue loader
  //                           ),
  //                           SizedBox(width: 10),
  //                           Text('Saving...'),
  //                         ],
  //                       )
  //                     : Text('Save', style: TextStyle(fontFamily: 'Poppins',color: Colors.green)),
  //                 onPressed: _isLoading
  //                     ? null
  //                     : () async {
  //                         setState(() {
  //                           _isLoading = true;
  //                         });
  //                         // String imageUrl = await _uploadImageToFirebaseStorage();
  //                         await updateProfileData(
  //                             docId,
  //                             firstNameController.text,
  //                             lastNameController.text,
  //                             usernameController.text,
  //                             mobileController.text,
  //                             cnicController.text);
  //                         setState(() {
  //                           _isLoading = false;
  //                         });
  //                         Navigator.of(context).pop();
  //                       },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  void showEditProfileDialog(Map<String, dynamic> data, String docId) {
    TextEditingController firstNameController =
        TextEditingController(text: data['FirstName']);
    TextEditingController lastNameController =
        TextEditingController(text: data['LastName']);
    TextEditingController usernameController =
        TextEditingController(text: data['Username']);
    TextEditingController mobileController =
        TextEditingController(text: data['Mobile']);
    TextEditingController cnicController =
        TextEditingController(text: data['CNIC']);
    TextEditingController aboutController =
        TextEditingController(text: data['About'] ?? ''); // New About field
    TextEditingController occupationController = TextEditingController(
        text: data['Occupation'] ?? ''); // New Occupation field
    TextEditingController skillsController = TextEditingController(
        text: (data['Skills'] ?? []).join(
            ', ')); // New Skills field, initially formatted as comma-separated string
    TextEditingController experienceController = TextEditingController(
        text: data['Experience']?.toString() ?? ''); // New Experience field
    TextEditingController addressController =
        TextEditingController(text: data['Address'] ?? ''); // New About field

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Profile",
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
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
                                InputDecoration(labelText: "First Name"),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(labelText: "Last Name"),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: usernameController,
                            decoration: InputDecoration(labelText: "Username"),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: mobileController,
                            decoration: InputDecoration(labelText: "Mobile"),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: cnicController,
                            decoration: InputDecoration(labelText: "CNIC"),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: aboutController,
                            decoration: InputDecoration(labelText: "About"),
                            maxLines: 3,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: occupationController,
                            decoration:
                                InputDecoration(labelText: "Occupation"),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: skillsController,
                            decoration: InputDecoration(
                                labelText: "Skills (comma-separated)"),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: experienceController,
                            decoration: InputDecoration(
                                labelText: "Experience (years)"),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: addressController,
                            decoration: InputDecoration(labelText: "Address"),
                          ),
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

                          await updateProfileData(
                            docId,
                            firstNameController.text,
                            lastNameController.text,
                            usernameController.text,
                            mobileController.text,
                            cnicController.text,
                            aboutController.text,
                            addressController.text,
                            occupationController.text,
                            skillsController.text
                                .split(',')
                                .map((s) => s.trim())
                                .toList(),
                            // Convert to list
                            int.tryParse(experienceController.text) ?? 0,
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
    String cnic,
    String about,
    String address,
    String occupation,
    List<String> skills,
    int experience,
  ) async {
    Map<String, dynamic> dataToUpdate = {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Mobile': mobile,
      'CNIC': cnic,
      'About': about,
      'Occupation': occupation,
      'Skills': skills,
      'Experience': experience,
      'Address': address
    };

    await FirebaseFirestore.instance
        .collection('provider')
        .doc(docId)
        .update(dataToUpdate)
        .then((value) => Fluttertoast.showToast(msg: "Profile Updated"))
        .catchError((error) =>
            Fluttertoast.showToast(msg: "Failed to update profile: $error"));
  }

// Future<void> updateProfileData(
//   String docId,
//   String firstName,
//   String lastName,
//   String username,
//   String mobile,
//   String cnic,
// ) async {
//   Map<String, dynamic> dataToUpdate = {
//     'FirstName': firstName,
//     'LastName': lastName,
//     'Username': username,
//     'Mobile': mobile,
//     'CNIC': cnic,
//   };
//   await FirebaseFirestore.instance
//       .collection('provider')
//       .doc(docId)
//       .update(dataToUpdate)
//       .then((value) => Fluttertoast.showToast(msg: "Profile Updated"))
//       .catchError((error) =>
//           Fluttertoast.showToast(msg: "Failed to update profile: $error"));
// }
}

class ProblemReportForm extends StatefulWidget {
  const ProblemReportForm({Key? key}) : super(key: key);

  @override
  _ProblemReportFormState createState() => _ProblemReportFormState();
}

class _ProblemReportFormState extends State<ProblemReportForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _problemDescriptionController =
  TextEditingController();
  String _selectedCategory = "Service Issue";

  final List<String> _categories = [
    "Service Issue",
    "Payment Problem",
    "App Bug",
    "Other"
  ];

  String _userType =
      "Provider"; // Simulated user type, dynamically fetched in real-world

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
      appBar: AppBar(
        title: const Text("Report a Problem",
            style:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Problem Category Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(category),
                              color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Problem Category",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Problem Description TextField
              TextFormField(
                controller: _problemDescriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Problem Description",
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a problem description";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _submitProblem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  icon: const FaIcon(FontAwesomeIcons.paperPlane,
                      color: Colors.white),
                  label: const Text("Submit",
                      style: TextStyle(fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to get icons for the categories
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Service Issue":
        return Icons.settings;
      case "Payment Problem":
        return Icons.payment;
      case "App Bug":
        return Icons.bug_report;
      default:
        return Icons.help_outline;
    }
  }

  // Handle the form submission
  void _submitProblem() {
    if (_formKey.currentState!.validate()) {
      String problemDescription = _problemDescriptionController.text;
      String selectedCategory = _selectedCategory;

      // Store the problem report with userType
      _storeProblemReport(problemDescription, selectedCategory, _userType);
    }
  }

  // Store problem report data (e.g., to Firestore)
  void _storeProblemReport(String description, String category,
      String userType) async {
    try {
      await FirebaseFirestore.instance.collection('problem_reports').add({
        'description': description,
        'category': category,
        'userType': userType,
        'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Problem report submitted successfully!")),
      );

      // Clear the form
      _problemDescriptionController.clear();
      Navigator.pop(context); // Close the bottom sheet
    } catch (error) {
      print("Failed to store problem report: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit report. Please try again.")),
      );
    }
  }
}