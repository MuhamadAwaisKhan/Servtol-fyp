import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:servtol/util/AppColors.dart';

class AddEditCEOScreen extends StatefulWidget {
  @override
  _AddEditCEOScreenState createState() => _AddEditCEOScreenState();
}

class _AddEditCEOScreenState extends State<AddEditCEOScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String title = '';
  String visionMission = '';
  String journey = '';
  List<String> achievements = [];
  String message = '';
  File? profileImage;
  String? profileImageUrl;
  // Add social media links variables
  String facebookLink = '';
  String instagramLink = '';
  String linkedinLink = '';
  String githubLink = '';


  // Fetching existing data from Firestore
  Future<DocumentSnapshot> _getCEODocument() async {
    return await FirebaseFirestore.instance.collection('about_ceo').doc('ceo_info').get();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('ceo_profile/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  // Show confirmation dialog before saving data

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    String profilePicUrl = '';

    if (profileImage != null) {
      profilePicUrl = await _uploadImage(profileImage!);
    } else {
      profilePicUrl = profileImageUrl ?? '';
    }

    await FirebaseFirestore.instance.collection('about_ceo').doc('ceo_info').set({
      'name': name,
      'title': title,
      'profile_pic_url': profilePicUrl,
      'vision_mission': visionMission,
      'journey': journey,
      'achievements': achievements,
      'message': message,
      'facebook': facebookLink,
      'instagram': instagramLink,
      'linkedin': linkedinLink,
      'github': githubLink,

    });

    Navigator.pop(context);
  }

  Future<void> _deleteData() async {
    await FirebaseFirestore.instance.collection('about_ceo').doc('ceo_info').delete();
    Navigator.pop(context);
  }
  Future<void> _showSaveConfirmationDialog() async {
    bool shouldSave = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Save"),
          content: Text("Are you sure you want to save these changes?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);  // Don't save
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);  // Save changes
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );

    if (shouldSave) {
      await _saveData();
    }
  }

  // Show confirmation dialog before deleting data
  Future<void> _showDeleteConfirmationDialog() async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this data? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);  // Don't delete
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);  // Delete data
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete) {
      await _deleteData();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          "Add/Edit Founder Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.heading),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<DocumentSnapshot>(
        future: _getCEODocument(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            // If no data exists, initialize empty fields for adding new details
            profileImageUrl = null;
            name = '';
            title = '';
            visionMission = '';
            journey = '';
            achievements = [];
            message = '';
            facebookLink = '';
            instagramLink = '';
            linkedinLink = '';
            githubLink = '';
          } else {
            // If data exists, populate the fields
            var data = snapshot.data!;
            profileImageUrl = data['profile_pic_url'] ?? null;
            name = data['name'] ?? '';
            title = data['title'] ?? '';
            visionMission = data['vision_mission'] ?? '';
            journey = data['journey'] ?? '';
            achievements = data['achievements'] != null
                ? List<String>.from(data['achievements'])
                : [];
            message = data['message'] ?? '';
            facebookLink = data['facebook'] ?? '';
            instagramLink = data['instagram'] ?? '';
            linkedinLink = data['linkedin'] ?? '';
            githubLink = data['github'] ?? '';
          }

          // Show the form regardless of data existence
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : (profileImageUrl != null
                          ? NetworkImage(profileImageUrl!) as ImageProvider<Object>?
                          : null),
                      child: profileImage == null && profileImageUrl == null
                          ? Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.blue,
                      )
                          : null,
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Name Field
                  _buildTextField(
                    label: "Name",
                    initialValue: name,
                    onSave: (value) => name = value!,
                    validator: (value) => value!.isEmpty ? "Please enter the name" : null,
                  ),
                  SizedBox(height: 15),
                  // Title Field
                  _buildTextField(
                    label: "Title",
                    initialValue: title,
                    onSave: (value) => title = value!,
                    validator: (value) => value!.isEmpty ? "Please enter the title" : null,
                  ),
                  SizedBox(height: 15),
                  // Vision & Mission Field
                  _buildTextField(
                    label: "Vision & Mission",
                    initialValue: visionMission,
                    maxLines: 3,
                    onSave: (value) => visionMission = value!,
                  ),
                  SizedBox(height: 15),
                  // Journey Field
                  _buildTextField(
                    label: "Journey",
                    initialValue: journey,
                    maxLines: 3,
                    onSave: (value) => journey = value!,
                  ),
                  SizedBox(height: 15),
                  // Achievements Field
                  _buildTextField(
                    label: "Achievements (comma separated)",
                    initialValue: achievements.join(', '),
                    onSave: (value) => achievements = value!.split(',').map((e) => e.trim()).toList(),
                  ),
                  SizedBox(height: 15),
                  // Message Field
                  _buildTextField(
                    label: "Message",
                    initialValue: message,
                    maxLines: 3,
                    onSave: (value) => message = value!,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    label: "Facebook Profile Link",
                    initialValue: facebookLink,
                    onSave: (value) => facebookLink = value!,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    label: "Instagram Profile Link",
                    initialValue: instagramLink,
                    onSave: (value) => instagramLink = value!,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    label: "Github Profile Link",
                    initialValue: githubLink,
                    onSave: (value) => githubLink = value!,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    label: "LinkedIn Profile Link",
                    initialValue: linkedinLink,
                    onSave: (value) => linkedinLink = value!,
                  ),
                  SizedBox(height: 30),
                  // Save Button
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text(
                      "Save Details",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      backgroundColor: AppColors.customButton,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    onPressed: _showSaveConfirmationDialog, // Save confirmation
                  ),
                  SizedBox(height: 10),
                  // Delete Button
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text(
                      "Delete Data",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    onPressed: _showDeleteConfirmationDialog, // Delete confirmation
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required void Function(String?) onSave,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17, color: Colors.blue),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(25),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(25),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      style: GoogleFonts.poppins(),
      maxLines: maxLines,
      onSaved: onSave,
      validator: validator,
    );
  }
}
