import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart'; // Assuming this is your utility class for UI elements

// Custom class to handle dropdown items
class DropdownItem {
  final String id;
  final String name;

  DropdownItem({required this.id, required this.name});
}

class ServicesAddition extends StatefulWidget {
  const ServicesAddition({Key? key}) : super(key: key);

  @override
  State<ServicesAddition> createState() => _ServicesAdditionState();
}

class _ServicesAdditionState extends State<ServicesAddition> {
  File? profilePic;  // This will store the image file

  TextEditingController nameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // TextEditingController durationController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedCategoryId,
      selectedSubcategoryId,
      selectedProvinceId,
      selectedCityId,
      selectedServiceTypeId,
      selectedtimestampId,
      selectedWageTypeId;
  String? selectedCategoryName,
      selectedSubcategoryName,
      selectedtimestampName,
      selectedProvinceName,
      selectedCityName,
      selectedServiceTypeName,
      selectedWageTypeName;

  List<DropdownItem> categoryItems = [];
  List<DropdownItem> subcategoryItems = [];
  List<DropdownItem> provinceItems = [];
  List<DropdownItem> cityItems = [];
  List<DropdownItem> serviceTypeItems = [];
  List<DropdownItem> wageTypeItems = [];
  List<DropdownItem> timestampItems = [];
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
    fetchFirestoreData('timestamp', timestampItems, null);
    print("Fetching timestamp data..."); // Debug print
  }

  void fetchFirestoreData(String collection, List<DropdownItem> itemList, Function? postFetch) {
    try {
      FirebaseFirestore.instance
          .collection(collection)
      .orderBy('Name')
          .get() // Use get() instead of snapshots() for initial data fetch
          .then((snapshot) {
        List<DropdownItem> items = snapshot.docs.map((doc) {
          print("Fetched item from $collection: ${doc['Name']}");
          return DropdownItem(id: doc.id, name: (doc['Name'] ?? 0).toString());        }).toList();
        setState(() {
          itemList.clear();
          itemList.addAll(items);
        });
        if (postFetch != null) postFetch();
      }).catchError((error) {
        print("Error fetching data from $collection: $error");
      });
    } catch (e) {
      print("Error fetching data from $collection: $e");
    }
  }
  void updateCategory() {
    if (selectedCategoryId != null) {
      fetchRelatedData(
          'Subcategory', 'categoryId', selectedCategoryId!, subcategoryItems);
    }
  }

  void updateProvince() {
    if (selectedProvinceId != null) {
      fetchRelatedData('City', 'provinceId', selectedProvinceId!, cityItems);
    }
  }

  void fetchRelatedData(String collection, String field, String value,
      List<DropdownItem> itemList) {
    FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: value)
        .snapshots()
        .listen((snapshot) {
      List<DropdownItem> items = snapshot.docs.map((doc) {
        return DropdownItem(id: doc.id, name: doc['Name'] ?? 'N/A');
      }).toList();
      setState(() {
        itemList.clear();
        itemList.addAll(items);
      });
    });
  }

  Future<String> _uploadImageToFirebaseStorage() async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('You are not logged in. Please log in and try again.')));
      return;
    }

    // Validation for required fields
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
        selectedtimestampName == null ||
        selectedServiceTypeId == null ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill all fields and select an image.')));
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      String imageUrl = await _uploadImageToFirebaseStorage();
      await FirebaseFirestore.instance.collection('service').add({
        'ServiceName': nameController.text.trim(),
        'Category': selectedCategoryName,
        'Subcategory': selectedSubcategoryName,
        'Province': selectedProvinceName,
        'City': selectedCityName,
        'Area': areaController.text.trim(),
        'Price': priceController.text.trim(),
        'Discount': discountController.text.trim(),
        'WageType': selectedWageTypeName,
        'ServiceType': selectedServiceTypeName,
        'Description': descriptionController.text.trim(),
        'ImageUrl': imageUrl,
        'Duration': selectedtimestampName,
        'providerId': currentUser.uid,
        'serviceNameLower': nameController.text.trim().toLowerCase(),
        // Correct lowercase version for searching
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Service added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add service: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false; // Stop loading regardless of the outcome
      });
    }
  }
  File? tempImage;  // Temporary storage for the new image before confirmation

  // Image picker method
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          tempImage = File(pickedFile.path);  // Store selected image in tempImage
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // Confirm the image selection
  void confirmUpload() {
    setState(() {
      profilePic = tempImage;  // Save the tempImage to profilePic on confirmation
      tempImage = null;  // Reset tempImage after confirmation
    });
  }

  // Cancel the image selection
  void cancelUpload() {
    setState(() {
      tempImage = null;  // Discard the selected image
    });
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
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: pickImage,  // Trigger the image picker when tapped
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profilePic != null
                              ? FileImage(profilePic!) as ImageProvider<Object>?
                              : null,
                          backgroundColor: Colors.blueGrey[200],  // Placeholder background color
                        ),
                        Positioned(
                          bottom: 0,
                          right: 120,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,  // Blue background for the upload icon
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),  // White border
                            ),
                            child: Icon(Icons.add,
                                color: Colors.white, size: 24),  // Add (+) icon
                          ),
                        ),
                        // Show OK (check) and Cancel (close) buttons only if an image is selected in tempImage
                        if (tempImage != null) ...[
                          Positioned(
                            right: 110,
                            top: 10,
                            child: GestureDetector(
                              onTap: confirmUpload,  // Confirm image selection
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green,  // Green background for OK button
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 110,
                            top: 10,
                            child: GestureDetector(
                              onTap: cancelUpload,  // Cancel image selection
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,  // Red background for Cancel button
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),                  // GestureDetector(
                  //   onTap: () async {
                  //     XFile? selectedImage = await ImagePicker()
                  //         .pickImage(source: ImageSource.gallery);
                  //     if (selectedImage != null) {
                  //       File convertedFile = File(selectedImage.path);
                  //       setState(() {
                  //         profilePic = convertedFile;
                  //       });
                  //     }
                  //   },
                  //   child: CircleAvatar(
                  //     radius: 64,
                  //     backgroundColor: Colors.grey[300],
                  //     backgroundImage:
                  //         profilePic != null ? FileImage(profilePic!) : null,
                  //     child: profilePic == null
                  //         ? Icon(FontAwesomeIcons.camera, size: 50)
                  //         : null,
                  //   ),
                  // ),
                  if (_isLoading)  // Conditionally render the loading indicator
                    Center( // Center the loading indicator
                      child: CircularProgressIndicator(),
                    ),
                  SizedBox(height: 20),
                  uihelper.CustomTextField(context,
                      nameController, "Service Name",
                      Icons.home_repair_service, false),
                  DropdownFields(), // Implement DropdownFields as shown earlier
                  uihelper.CustomTextField(context,
                      areaController, "Area", Icons.map, false),
                  uihelper.CustomNumberField(context,
                      priceController, "Price", Icons.money, false),
                  uihelper.CustomNumberField(
                    context,
                      discountController, "Discount %", Icons.percent, false),
                  // uihelper.CustomTextField(durationController, "Time Slot",
                  //     Icons.data_usage_rounded,false ),
                  uihelper.customDescriptionField(
                    descriptionController, "Description",
                    // Icons.description
                  ),
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

  Widget DropdownFields() {
    return Column(
      children: [
        // Category Dropdown
        uihelper.customDropdownButtonFormField(
          value: selectedCategoryId,
          items: categoryItems.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              var selectedItem =
                  categoryItems.firstWhere((item) => item.id == value);
              setState(() {
                selectedCategoryId = value;
                selectedCategoryName = selectedItem.name;
                selectedSubcategoryId =
                    null; // Reset subcategory on category change
                fetchRelatedData(
                    'Subcategory', 'categoryId', value, subcategoryItems);
              });
            }
          },
          labelText: "Select Category",
        ),
        // Subcategory Dropdown
        uihelper.customDropdownButtonFormField(
          value: selectedSubcategoryId,
          items: subcategoryItems.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              var selectedItem =
                  subcategoryItems.firstWhere((item) => item.id == value);
              setState(() {
                selectedSubcategoryId = value;
                selectedSubcategoryName = selectedItem.name;
              });
            }
          },
          labelText: "Select Subcategory",
        ),
        // Province Dropdown
        uihelper.customDropdownButtonFormField(
          value: selectedProvinceId,
          items: provinceItems.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              var selectedItem =
                  provinceItems.firstWhere((item) => item.id == value);
              setState(() {
                selectedProvinceId = value;
                selectedProvinceName = selectedItem.name;
                selectedCityId = null; // Reset city on province change
                fetchRelatedData('City', 'provinceId', value, cityItems);
              });
            }
          },
          labelText: "Select Province",
        ),
        // City Dropdown
        uihelper.customDropdownButtonFormField(
          value: selectedCityId,
          items: cityItems.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              var selectedItem =
                  cityItems.firstWhere((item) => item.id == value);
              setState(() {
                selectedCityId = value;
                selectedCityName = selectedItem.name;
              });
            }
          },
          labelText: "Select City",
        ),
        // Service Type Dropdown
        uihelper.customDropdownButtonFormField(
          value: selectedServiceTypeId,
          items: serviceTypeItems.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              var selectedItem =
                  serviceTypeItems.firstWhere((item) => item.id == value);
              setState(() {
                selectedServiceTypeId = value;
                selectedServiceTypeName = selectedItem.name;
              });
            }
          },
          labelText: "Select Service Type",
        ),
        uihelper.customDropdownButtonFormField(
          value: selectedtimestampId,
          items: timestampItems.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text('${item.name} minutes'),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              var selectedItem = timestampItems.firstWhere((item) => item.id == value);
              setState(() {
                selectedtimestampId = value;
                selectedtimestampName = '${selectedItem.name} minutes';
              });
            }
          },
          labelText: "Select Duration",
        ),

        // Wage Type Dropdown
        uihelper.customDropdownButtonFormField(
          value: selectedWageTypeId,
          items: wageTypeItems.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              var selectedItem =
                  wageTypeItems.firstWhere((item) => item.id == value);
              setState(() {
                selectedWageTypeId = value;
                selectedWageTypeName = selectedItem.name;
              });
            }
          },
          labelText: "Select Wage Type",
        ),
        // if (_isLoading)
        //   Positioned(
        //     child: Container(
        //       color: Colors.black45,
        //       child: Center(child: CircularProgressIndicator()),
        //     ),
        //   ),
      ],
    );
  }
}
