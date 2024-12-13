import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/AppColors.dart';

class AddTributeScreen extends StatefulWidget {
  @override
  _AddTributeScreenState createState() => _AddTributeScreenState();
}

class _AddTributeScreenState extends State<AddTributeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _occupationController = TextEditingController();
  final _detailsController = TextEditingController();
  File? _pickedImage;
  String? _imageUrl;
  String? selectedTributeId; // Tracks whether we are editing
  bool isSubmitting = false;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    _nameController.dispose();
    _occupationController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      setState(() {
        isLoading = true;
      });
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('tribute_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  void addOrUpdateTribute() async {
    if (_formKey.currentState!.validate() && !isSubmitting) {
      setState(() {
        isSubmitting = true;
      });

      // Upload the image if it was picked
      if (_pickedImage != null) {
        _imageUrl = await _uploadImageToFirebase(_pickedImage!);
      }

      try {
        final data = {
          'name': _nameController.text,
          'pictureUrl': _imageUrl ?? '',  // Use the image URL if available, otherwise use the default
          'occupation': _occupationController.text,
          'details': _detailsController.text,
        };

        if (selectedTributeId == null) {
          // Add Tribute
          await FirebaseFirestore.instance.collection('tributes').add(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tribute added successfully!')),
          );
        } else {
          // Update Tribute
          await FirebaseFirestore.instance
              .collection('tributes')
              .doc(selectedTributeId)
              .update(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tribute updated successfully!')),
          );
        }

        _resetForm(); // Reset the form after saving
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save tribute: $e')),
        );
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _nameController.clear();
      _occupationController.clear();
      _detailsController.clear();
      _pickedImage = null;
      _imageUrl = null;
      selectedTributeId = null;  // Reset the tribute ID after adding or updating
    });
  }

  void deleteTribute(String tributeId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Tribute'),
        content: Text('Are you sure you want to delete this tribute?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;

    if (shouldDelete) {
      await FirebaseFirestore.instance
          .collection('tributes')
          .doc(tributeId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tribute deleted successfully!')),
      );
    }
  }

  void editTribute(DocumentSnapshot tribute) {
    setState(() {
      selectedTributeId = tribute.id;
      _nameController.text = tribute['name'];
      _occupationController.text = tribute['occupation'];
      _detailsController.text = tribute['details'];
      _imageUrl = tribute['pictureUrl'];
      _pickedImage = null; // Reset picked image to ensure new one is optional
    });

    // Scroll to the top of the form after setting the state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget buildTributeList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('tributes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No tributes added yet.',
              style:
              GoogleFonts.poppins(fontSize: 16, color: AppColors.heading),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final tribute = snapshot.data!.docs[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: tribute['pictureUrl'] != null
                    ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: tribute['pictureUrl'],
                    placeholder: (context, url) =>
                        CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        Icon(FontAwesomeIcons.exclamationCircle),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
                    : CircleAvatar(
                  backgroundColor: AppColors.background,
                  child: Icon(FontAwesomeIcons.person, color: Colors.white),
                ),
                title: Text(
                  tribute['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                subtitle: Text(
                  tribute['occupation'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue.withOpacity(0.7),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(FontAwesomeIcons.solidEdit, color: Colors.blue),
                      onPressed: () => editTribute(tribute),
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.trashCan, color: Colors.red),
                      onPressed: () => deleteTribute(tribute.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  final _scrollController = ScrollController(); // Add a scroll controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    selectedTributeId == null ? 'Pay Tribute' : 'Edit Tribute',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController, // Attach the scroll controller
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header Text

                      Text(
                        'Share details of the person you want to honor.',
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.blueGrey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      // Form Section
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  shape: BoxShape.circle,
                                  border:
                                  Border.all(color: Colors.blue, width: 2),
                                ),
                                child: _pickedImage != null
                                    ? ClipOval(
                                  child: Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : (_imageUrl != null
                                    ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: _imageUrl!,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget:
                                        (context, url, error) =>
                                        Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : Icon(FontAwesomeIcons.cameraRetro,
                                    size: 40, color: Colors.blue)),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController, // Use the controller
                              decoration: InputDecoration(
                                labelText: 'Name',
                                labelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 2.0),
                                  // Blue border when focused
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                  // Grey border when not focused
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Name cannot be empty'
                                  : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _occupationController, // Use the controller
                              decoration: InputDecoration(
                                labelText: 'Occupation',
                                labelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 2.0),
                                  // Blue border when focused
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                  // Grey border when not focused
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              // validator: (value) => value!.isEmpty
                              //     ? 'Occupation cannot be empty'
                              //     : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _detailsController, // Use the controller
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Details',
                                labelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 2.0),
                                  // Blue border when focused
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                  // Grey border when not focused
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Details cannot be empty'
                                  : null,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed:
                              isSubmitting ? null : addOrUpdateTribute,
                              icon: isSubmitting
                                  ? CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                                  : Icon(FontAwesomeIcons.solidFloppyDisk),
                              label: Text(isSubmitting
                                  ? 'Saving...'
                                  : selectedTributeId == null
                                  ? 'Save Tribute'
                                  : 'Update Tribute'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                textStyle: GoogleFonts.poppins(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      buildTributeList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}