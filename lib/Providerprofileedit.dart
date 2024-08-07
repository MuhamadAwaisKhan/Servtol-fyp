// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:servtol/loginprovider.dart'; // Ensure this is the correct import path.
//
// class ProfileScreenWidget extends StatefulWidget {
//   @override
//   _ProfileScreenWidgetState createState() => _ProfileScreenWidgetState();
// }
//
// class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final ImagePicker _picker = ImagePicker();
//   File? _image;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         title: Text("Profile Section"),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('provider')
//             .where('Email', isEqualTo: _auth.currentUser?.email)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No data available"));
//           }
//
//           var docSnapshot = snapshot.data!.docs.first;
//           var doc = docSnapshot.data() as Map<String, dynamic>;
//           var docId = docSnapshot.id;
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 _buildUserAvatar(doc),
//                 SizedBox(height: 20),
//                 detailItem('First Name:', doc['FirstName']),
//                 detailItem('Last Name:', doc['LastName']),
//                 detailItem('Username:', doc['Username']),
//                 detailItem('Email:', doc['Email']),
//                 detailItem('Mobile:', doc['Mobile']),
//                 detailItem('CNIC:', doc['CNIC']),
//                 SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: () => showEditProfileDialog(doc, docId),
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
//                   child: Text('Edit Profile', style: TextStyle(fontSize: 18, color: Colors.white)),
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: logout,
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
//                   child: Text('Logout', style: TextStyle(fontSize: 18, color: Colors.white)),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildUserAvatar(Map<String, dynamic> doc) {
//     ImageProvider? imageProvider;
//     if (_image != null) {
//       imageProvider = FileImage(_image!);
//     } else if (doc['ProfilePic'] != null && doc['ProfilePic'] is String) {
//       imageProvider = NetworkImage(doc['ProfilePic']);
//     }
//
//     return CircleAvatar(
//       radius: 60,
//       backgroundImage: imageProvider,
//       child: imageProvider == null ? Icon(Icons.person, size: 60, color: Colors.grey[200]) : null,
//       backgroundColor: Colors.deepPurple[200],
//     );
//   }
//
//
//   Widget detailItem(String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
//           Text(value ?? 'Not provided', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
//         ],
//       ),
//     );
//   }
//
//   void showEditProfileDialog(Map<String, dynamic> doc, String docId) {
//     TextEditingController firstNameController = TextEditingController(text: doc['FirstName']);
//     TextEditingController lastNameController = TextEditingController(text: doc['LastName']);
//     TextEditingController usernameController = TextEditingController(text: doc['Username']);
//     TextEditingController mobileController = TextEditingController(text: doc['Mobile']);
//     TextEditingController cnicController = TextEditingController(text: doc['CNIC']);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Edit Profile"),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 GestureDetector(
//                   onTap: pickImage,
//                   child: CircleAvatar(
//                     radius: 60,
//                     backgroundImage: _image != null ? FileImage(_image!) : (doc['ProfilePic'] != null ? NetworkImage(doc['ProfilePic']) : null),
//                     child: _image == null && doc['ProfilePic'] == null ? Icon(Icons.add_a_photo, size: 60, color: Colors.grey[200]) : null,
//                   ),
//                 ),
//                 TextField(controller: firstNameController, decoration: InputDecoration(labelText: "First Name")),
//                 TextField(controller: lastNameController, decoration: InputDecoration(labelText: "Last Name")),
//                 TextField(controller: usernameController, decoration: InputDecoration(labelText: "Username")),
//                 TextField(controller: mobileController, decoration: InputDecoration(labelText: "Mobile")),
//                 TextField(controller: cnicController, decoration: InputDecoration(labelText: "CNIC")),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: Text('Save'),
//               onPressed: () async {
//                 String imageUrl = await _uploadImageToFirebaseStorage(); // Handle image upload and update
//                 updateProfileData(docId, firstNameController.text, lastNameController.text, usernameController.text, mobileController.text, cnicController.text, imageUrl);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<String> _uploadImageToFirebaseStorage() async {
//     if (_image == null) {
//       return ''; // Return empty if no image is selected
//     }
//     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference reference = FirebaseStorage.instance.ref().child('images/profile/$fileName.jpg');
//     UploadTask uploadTask = reference.putFile(_image!);
//     TaskSnapshot storageTaskSnapshot = await uploadTask;
//     return await storageTaskSnapshot.ref.getDownloadURL();
//   }
//
//   void updateProfileData(String docId, String firstName, String lastName, String username, String mobile, String cnic, String imageUrl) {
//     Map<String, dynamic> dataToUpdate = {
//       'FirstName': firstName,
//       'LastName': lastName,
//       'Username': username,
//       'Mobile': mobile,
//       'CNIC': cnic,
//       'ProfilePic': imageUrl.isNotEmpty ? imageUrl : null
//     };
//     FirebaseFirestore.instance.collection('provider').doc(docId).update(dataToUpdate)
//         .then((value) => Fluttertoast.showToast(msg: "Profile Updated"))
//         .catchError((error) => Fluttertoast.showToast(msg: "Failed to update profile: $error"));
//   }
//
//   void logout() async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginprovider()));
//     Fluttertoast.showToast(msg: "Logged out successfully");
//   }
//
//
// }
