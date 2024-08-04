import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/uihelper.dart';

class ServiceDetailScreen extends StatefulWidget {
  final DocumentSnapshot service;

  ServiceDetailScreen({required this.service});

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // String _errorMessage = '';


  bool _isLoading = false;
  File? profilePic;
  final ImagePicker imagePicker = ImagePicker();

  String? selectedCategoryId,
      selectedSubcategoryId,
      selectedProvinceId,
      selectedCityId,
      selectedServiceTypeId,
      selectedWageTypeId;
  List<DropdownMenuItem<String>> categoryItems = [],
      subcategoryItems = [],
      provinceItems = [],
      cityItems = [],
      serviceTypeItems = [],
      wageTypeItems = [];

  @override
  void initState() {
    super.initState();
    initializeControllers();
    fetchDropdownData();
  }

  void initializeControllers() {
    nameController.text = widget.service.get('ServiceName') ?? '';
    areaController.text = widget.service.get('Area') ?? '';
    priceController.text = widget.service.get('Price') ?? '';
    timeController.text = widget.service.get('TimeSlot') ?? '';
    discountController.text = widget.service.get('Discount') ?? '';
    descriptionController.text = widget.service.get('Description') ?? '';
  }

  void fetchDropdownData() {
    fetchFirestoreData('Category', categoryItems);
    fetchFirestoreData('Province', provinceItems);
    fetchFirestoreData('ServiceTypes', serviceTypeItems);
    fetchFirestoreData('wageTypes', wageTypeItems);
  }

  void fetchFirestoreData(
      String collection, List<DropdownMenuItem<String>> itemList) {
    FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .listen((snapshot) {
      List<DropdownMenuItem<String>> items = snapshot.docs.map((doc) {
        return DropdownMenuItem(
            value: doc.id, child: Text(doc.get('Name') ?? 'N/A'));
      }).toList();
      setState(() {
        itemList.clear();
        itemList.addAll(items);
      });
    });
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
            value: doc.id, child: Text(doc.get('Name') ?? 'N/A'));
      }).toList();
      if (mounted) {
        setState(() {
          itemList.clear();
          itemList.addAll(items);
        });
      }
    });
  }

  // Future<void> _updateData() async {
  //   if (_isLoading) return;
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     String imageUrl = profilePic != null ? await _uploadImageToFirebaseStorage() : widget.service.get('ImageUrl');
  //     await FirebaseFirestore.instance.collection('service').doc(widget.service.id).update({
  //       'ServiceName': nameController.text.trim(),
  //       'Area': areaController.text.trim(),
  //       'Price': priceController.text.trim(),
  //       'TimeSlot': timeController.text.trim(),
  //       'Discount': discountController.text.trim(),
  //       'Description': descriptionController.text.trim(),
  //       'ImageUrl': imageUrl,
  //       'CategoryId': selectedCategoryId,
  //       'SubcategoryId': selectedSubcategoryId,
  //       'ProvinceId': selectedProvinceId,
  //       'CityId': selectedCityId,
  //       'ServiceTypeId': selectedServiceTypeId,
  //       'WageTypeId': selectedWageTypeId,
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Service updated successfully')));
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update service: $e')));
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _deleteData(String documentId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('service')
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service deleted successfully')));
      Navigator.of(context).pop(); // Optionally pop the screen if needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete service: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadImageToFirebaseStorage() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child('images/Servicepics/$fileName');
    UploadTask uploadTask = reference.putFile(profilePic!);
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    return await storageTaskSnapshot.ref.getDownloadURL();
  }

  bool _validateFields() {
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
      return false;
    }
    return true;
  }

  Future<void> _updateData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = profilePic != null
          ? await _uploadImageToFirebaseStorage()
          : widget.service.get('ImageUrl');
      await FirebaseFirestore.instance
          .collection('service')
          .doc(widget.service.id)
          .update({
        'ServiceName': nameController.text.trim(),
        'Area': areaController.text.trim(),
        'Price': priceController.text.trim(),
        'TimeSlot': timeController.text.trim(),
        'Discount': discountController.text.trim(),
        'Description': descriptionController.text.trim(),
        'ImageUrl': imageUrl,
        'CategoryId': selectedCategoryId,
        'SubcategoryId': selectedSubcategoryId,
        'ProvinceId': selectedProvinceId,
        'CityId': selectedCityId,
        'ServiceTypeId': selectedServiceTypeId,
        'WageTypeId': selectedWageTypeId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service updated successfully')));
      Navigator.of(context).pop(); // Pop the edit dialog after success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update service: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _updateData() async {
  //   print("Updating data");
  //   if (_isLoading) {
  //     print("Update skipped, already loading");
  //     return;
  //   }
  //
  //   setState(() {
  //     _isLoading = true;
  //     print("Loading state set to true");
  //   });
  //
  //   try {
  //     String imageUrl = profilePic != null ? await _uploadImageToFirebaseStorage() : widget.service.get('ImageUrl');
  //     print("Image URL: $imageUrl");
  //     await FirebaseFirestore.instance.collection('service').doc(widget.service.id).update({
  //       'ServiceName': nameController.text.trim(),
  //       'Area': areaController.text.trim(),
  //       'Price': priceController.text.trim(),
  //       'TimeSlot': timeController.text.trim(),
  //       'Discount': discountController.text.trim(),
  //       'Description': descriptionController.text.trim(),
  //       'ImageUrl': imageUrl,
  //       'CategoryId': selectedCategoryId,
  //       'SubcategoryId': selectedSubcategoryId,
  //       'ProvinceId': selectedProvinceId,
  //       'CityId': selectedCityId,
  //       'ServiceTypeId': selectedServiceTypeId,
  //       'WageTypeId': selectedWageTypeId,
  //     });
  //     print("Update successful");
  //   } catch (e) {
  //     print("Failed to update service: $e");
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //       print("Loading state set to false");
  //     });
  //   }
  // }

// Inside the "Save" button onPressed:

  Widget _buildDropdown(String label, String? value,
      List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  void _showEditConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Edit"),
          content: Text("Are you sure you want to edit this service?"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(color: Colors.grey[600]),
          actions: <Widget>[
            TextButton(
              child: Text("No", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Yes", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _showEditDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog() {
    bool _isLoading = false; // Local state for loading indicator
    String? _errorMessage; // Nullable local state for error messages

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on tap outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Edit Service Details"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    if (_isLoading)
                      Center(child: CircularProgressIndicator()),
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)), // Use '!' to assert non-null based on preceding if-check
                      ),
                    GestureDetector(
                      onTap: () async {
                        XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
                        if (selectedImage != null) {
                          setState(() {
                            profilePic = File(selectedImage.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.grey,
                        backgroundImage: profilePic != null ? FileImage(profilePic!) : null,
                        child: profilePic == null ? Icon(Icons.camera_alt, size: 50) : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Service Name'),
                    ),
                    SizedBox(height: 10),
                    _buildDropdown(
                        "Category", selectedCategoryId, categoryItems,
                        (String? newValue) {
                      setState(() {
                        selectedCategoryId = newValue;
                        selectedSubcategoryId = null;
                        fetchRelatedData('Subcategory', 'categoryId', newValue!,
                            subcategoryItems);
                      });
                    }),
                    SizedBox(height: 10),
                    _buildDropdown(
                        "Subcategory", selectedSubcategoryId, subcategoryItems,
                        (String? newValue) {
                      setState(() {
                        selectedSubcategoryId = newValue;
                      });
                    }),
                    SizedBox(height: 10),
                    _buildDropdown(
                        "Province", selectedProvinceId, provinceItems,
                        (String? newValue) {
                      setState(() {
                        selectedProvinceId = newValue;
                        selectedCityId = null;
                        fetchRelatedData(
                            'City', 'provinceId', newValue!, cityItems);
                      });
                    }),
                    SizedBox(height: 10),
                    _buildDropdown("City", selectedCityId, cityItems,
                        (String? newValue) {
                      setState(() {
                        selectedCityId = newValue;
                      });
                    }),
                    SizedBox(height: 10),
                    _buildDropdown(
                        "Service Type", selectedServiceTypeId, serviceTypeItems,
                        (String? newValue) {
                      setState(() {
                        selectedServiceTypeId = newValue;
                      });
                    }),
                    SizedBox(height: 10),
                    _buildDropdown(
                        "Wage Type", selectedWageTypeId, wageTypeItems,
                        (String? newValue) {
                      setState(() {
                        selectedWageTypeId = newValue;
                      });
                    }),
                    TextField(
                      controller: areaController,
                      decoration: InputDecoration(labelText: 'Area'),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                    ),
                    TextField(
                      controller: timeController,
                      decoration: InputDecoration(labelText: 'Time Slot'),
                    ),
                    TextField(
                      controller: discountController,
                      decoration: InputDecoration(labelText: 'Discount %'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (!_isLoading) // Hide actions when loading
                  TextButton(
                    child: Text('Cancel', style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                if (!_isLoading) // Hide actions when loading
                  TextButton(
                    child: Text('Save', style: TextStyle(color: Colors.green)),
                    onPressed: () {
                      if (_validateFields()) {
                        setState(() => _isLoading = true);
                        _updateData().then((_) {
                          Navigator.of(context).pop(); // Close dialog after update
                        }).catchError((error) {
                          setState(() {
                            _isLoading = false;
                            _errorMessage = 'Failed to update service: $error';
                            // Reset the error message after 2 to 3 seconds
                            Future.delayed(Duration(seconds: 3), () {
                              setState(() {
                                _errorMessage = null;
                              });
                            });
                          });
                        });
                      }
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this service?"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(color: Colors.grey[600]),
          actions: <Widget>[
            TextButton(
              child: Text("No", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Yes", style: TextStyle(color: Colors.green)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteData(widget.service.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Service Details",
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        backgroundColor: Colors.teal,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.service['ImageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.service['ImageUrl'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.image_not_supported, size: 200),
              SizedBox(height: 20),
              Column(
                children: [
                  uihelper.detailCard("Service Name",
                      widget.service['ServiceName'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Category", widget.service['Category'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Price", widget.service['Price'] ?? 'Not provided'),
                  uihelper.detailCard("Service Type",
                      widget.service['ServiceType'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Discount", "${widget.service['Discount'] ?? '0'}%"),
                  uihelper.detailCard("Subcategory",
                      widget.service['Subcategory'] ?? 'Not provided'),
                  uihelper.detailCard("Wage Type",
                      widget.service['WageType'] ?? 'Not provided'),
                  uihelper.detailCard("Time Slot",
                      widget.service['TimeSlot'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Province", widget.service['Province'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "City", widget.service['City'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Area", widget.service['Area'] ?? 'Not provided'),
                  uihelper.detailCard("Description",
                      widget.service['Description'] ?? 'Not provided',
                      lastItem: true),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  uihelper.actionButton('Delete', Colors.red,
                      Icons.dangerous_outlined, _showDeleteConfirmation),
                  uihelper.actionButton(
                      'Edit', Colors.blue, Icons.edit, _showEditConfirmation),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
