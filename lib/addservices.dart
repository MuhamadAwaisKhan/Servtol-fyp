import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart'; // Assuming this is your utility class for UI elements
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServicesAddition extends StatefulWidget {
  const ServicesAddition({Key? key}) : super(key: key);

  @override
  State<ServicesAddition> createState() => _ServicesAdditionState();
}

class _ServicesAdditionState extends State<ServicesAddition> {
  TextEditingController nameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? profilePic;
  String? selectedCategoryId,
      selectedSubcategoryId,
      selectedProvinceId,
      selectedCityId,
      selectedServiceTypeId,
      selectedWageTypeId;
  List<DropdownMenuItem<String>> categoryItems = [];
  List<DropdownMenuItem<String>> subcategoryItems = [];
  List<DropdownMenuItem<String>> provinceItems = [];
  List<DropdownMenuItem<String>> cityItems = [];
  List<DropdownMenuItem<String>> serviceTypeItems = [];
  List<DropdownMenuItem<String>> wageTypeItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  fetchDropdownData() {
    fetchFirestoreData('Category', categoryItems, updateCategory);
    fetchFirestoreData('Province', provinceItems, updateProvince);
    fetchFirestoreData('ServiceTypes', serviceTypeItems, null);
    fetchFirestoreData('wageTypes', wageTypeItems, null);
  }

  void fetchFirestoreData(String collection,
      List<DropdownMenuItem<String>> itemList, Function? postFetch) {
    FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .listen((snapshot) {
      List<DropdownMenuItem<String>> items = snapshot.docs.map((doc) {
        return DropdownMenuItem(
            value: doc.id, child: Text(doc['Name'] ?? 'N/A'));
      }).toList();
      setState(() {
        itemList.clear();
        itemList.addAll(items);
      });
      if (postFetch != null) postFetch();
    });
  }

  void updateCategory() {
    if (selectedCategoryId != null)
      fetchRelatedData(
          'Subcategory', 'categoryId', selectedCategoryId!, subcategoryItems);
  }

  void updateProvince() {
    if (selectedProvinceId != null)
      fetchRelatedData('City', 'provinceId', selectedProvinceId!, cityItems);
  }

  void fetchRelatedData(String collection, String field, String value,
      List<DropdownMenuItem<String>> itemList) {
    FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: value)
        .snapshots()
        .listen((snapshot) {
      List<DropdownMenuItem<String>> items = snapshot.docs.map((doc) {
        return DropdownMenuItem(
            value: doc.id, child: Text(doc['Name'] ?? 'N/A'));
      }).toList();
      setState(() {
        itemList.clear();
        itemList.addAll(items);
      });
    });
  }

  Future<String> _uploadImageToFirebaseStorage() async {
    try {
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      Reference reference = FirebaseStorage.instance
          .ref()
          .child('images/Servicepics/$fileName.jpg');
      UploadTask uploadTask = reference.putFile(profilePic!);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String downloadURL = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Failed to upload image to Firebase Storage: $e');
    }
  }

  Future<void> _addData() async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text('You are not logged in. Please log in and try again.')));
      return;
    }

    if (profilePic == null ||
        nameController.text.isEmpty ||
        selectedCategoryId == null ||
        selectedSubcategoryId == null ||
        selectedProvinceId == null ||
        selectedCityId == null ||
        areaController.text.isEmpty ||
        priceController.text.isEmpty ||
        discountController.text.isEmpty ||
        selectedWageTypeId == null ||
        selectedServiceTypeId == null ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill all fields and select an image')));
      return;
    }
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      String imageUrl = await _uploadImageToFirebaseStorage();
      await FirebaseFirestore.instance.collection('service').add({
        'ServiceName': nameController.text.trim(),
        'Category': selectedCategoryId,
        'Subcategory': selectedSubcategoryId,
        'Province': selectedProvinceId,
        'City': selectedCityId,
        'Area': areaController.text.trim(),
        'Price': priceController.text.trim(),
        'Discount': discountController.text.trim(),
        'WageType': selectedWageTypeId,
        'ServiceType': selectedServiceTypeId,
        'Description': descriptionController.text.trim(),
        'ImageUrl': imageUrl,
        'TimeSlot': timeController.text.trim(),
        'providerId': FirebaseAuth.instance.currentUser!.uid,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Service added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add service: $e')));
    } finally {
      setState(() {
        _isLoading = false; // Stop loading regardless of outcome
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add New Service",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () async {
                      XFile? selectedImage = await ImagePicker().pickImage(
                          source: ImageSource.gallery);
                      if (selectedImage != null) {
                        File convertedFile = File(selectedImage.path);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                content: Text("Image Selected!"));
                          },
                        );
                        setState(() {
                          profilePic = convertedFile;
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                content: Text("No Image Selected!"));
                          },
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: profilePic != null ? FileImage(
                          profilePic!) : null,
                      child: profilePic == null ? Icon(
                          FontAwesomeIcons.camera, size: 50) : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  uihelper.CustomTextField(
                      nameController, "Service Name", Icons.home_repair_service,
                      false),
                  uihelper.customDropdownButtonFormField(
                    value: selectedCategoryId,
                    items: categoryItems,
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                        selectedSubcategoryId =
                        null; // Reset subcategory on category change
                        fetchRelatedData('Subcategory', 'categoryId', value!,
                            subcategoryItems);
                      });
                    },
                    labelText: "Select Category",
                  ),
                  uihelper.customDropdownButtonFormField(
                    value: selectedSubcategoryId,
                    items: subcategoryItems,
                    onChanged: (value) =>
                        setState(() => selectedSubcategoryId = value),
                    labelText: "Select Subcategory",
                  ),
                  uihelper.customDropdownButtonFormField(
                    value: selectedProvinceId,
                    items: provinceItems,
                    onChanged: (value) {
                      setState(() {
                        selectedProvinceId = value;
                        selectedCityId = null; // Reset city on province change
                        fetchRelatedData(
                            'City', 'provinceId', value!, cityItems);
                      });
                    },
                    labelText: "Select Province",
                  ),
                  uihelper.customDropdownButtonFormField(
                    value: selectedCityId,
                    items: cityItems,
                    onChanged: (value) =>
                        setState(() => selectedCityId = value),
                    labelText: "Select City",
                  ),
                  uihelper.customDropdownButtonFormField(
                    value: selectedServiceTypeId,
                    items: serviceTypeItems,
                    onChanged: (value) =>
                        setState(() => selectedServiceTypeId = value),
                    labelText: "Select Service Type",
                  ),
                  uihelper.customDropdownButtonFormField(
                    value: selectedWageTypeId,
                    items: wageTypeItems,
                    onChanged: (value) =>
                        setState(() => selectedWageTypeId = value),
                    labelText: "Select Wage Type",
                  ),
                  uihelper.CustomTextField(
                      areaController, "Area", Icons.map, false),
                  uihelper.CustomNumberField(
                      priceController, "Price", Icons.money, false),
                  uihelper.CustomNumberField(
                      discountController, "Discount %", Icons.percent, false),
                  uihelper.CustomTimeDuration(
                      timeController, "Time Slot", Icons.timer,
                      "Day:Hour:Min==00:00:00"),
                  uihelper.customDescriptionField(
                      descriptionController, "Description", Icons.description),
                  SizedBox(height: 20),
                  uihelper.CustomButton(() {
                    if (!_isLoading) {
                      _addData();
                    }
                  }, _isLoading ? 'Saving...' : "Save", 50, 120),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned(
              child: Container(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}