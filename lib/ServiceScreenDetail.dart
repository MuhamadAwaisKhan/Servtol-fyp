import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/uihelper.dart'; // Assuming this is your utility class for UI elements

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
  TextEditingController durationController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initializeControllers();
    fetchDropdownData();
  }

  void initializeControllers() {
    Map<String, dynamic>? serviceData =
        widget.service.data() as Map<String, dynamic>?;

    // Use a local function to simplify null checking and default values
    String safeGet(String field, {String defaultValue = ''}) {
      return serviceData != null && serviceData.containsKey(field)
          ? serviceData[field] ?? defaultValue
          : defaultValue;
    }

    nameController.text = safeGet('ServiceName');
    areaController.text = safeGet('Area');
    priceController.text = safeGet('Price');
    durationController.text = safeGet('Duration');
    discountController.text = safeGet('Discount');
    descriptionController.text = safeGet('Description');

    // Initialize ID fields; consider using null if the field is missing
    selectedCategoryId =
        serviceData != null && serviceData.containsKey('CategoryId')
            ? serviceData['CategoryId']
            : null;
    selectedSubcategoryId =
        serviceData != null && serviceData.containsKey('SubcategoryId')
            ? serviceData['SubcategoryId']
            : null;
    selectedProvinceId =
        serviceData != null && serviceData.containsKey('ProvinceId')
            ? serviceData['ProvinceId']
            : null;
    selectedCityId = serviceData != null && serviceData.containsKey('CityId')
        ? serviceData['CityId']
        : null;
    selectedServiceTypeId =
        serviceData != null && serviceData.containsKey('ServiceTypeId')
            ? serviceData['ServiceTypeId']
            : null;
    selectedWageTypeId =
        serviceData != null && serviceData.containsKey('WageTypeId')
            ? serviceData['WageTypeId']
            : null;

    // Fetch related data if IDs are available
    if (selectedCategoryId != null) {
      fetchRelatedData(
          'Subcategory', 'categoryId', selectedCategoryId!, subcategoryItems);
    }
    if (selectedProvinceId != null) {
      fetchRelatedData('City', 'provinceId', selectedProvinceId!, cityItems);
    }
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

  Future<String> _uploadImageToFirebaseStorage() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child('images/Servicepics/$fileName');
    UploadTask uploadTask = reference.putFile(profilePic!);
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    return await storageTaskSnapshot.ref.getDownloadURL();
  }

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

  bool validateFields() {
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
      _errorMessage = "Please fill all fields and select an image.";
      // setState(() {}); // Trigger a rebuild to show the error message
      return false;
    }
    _errorMessage = null; // Clear error message if everything is valid
    return true;
  }

  //   List<String?> fields = [
  //     nameController.text,
  //     areaController.text,
  //     priceController.text,
  //     timeController.text,
  //     discountController.text,
  //     descriptionController.text,
  //     selectedCategoryId,
  //     selectedSubcategoryId,
  //     selectedProvinceId,
  //     selectedCityId,
  //     selectedServiceTypeId,
  //     selectedWageTypeId,
  //   ];
  //   return fields.every((field) => field != null && field.isNotEmpty);
  // }

  Future<void> _updateData() async {
    if (_isLoading) {
      return;
    }

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
        'Duration': durationController.text.trim(),
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
    bool _isLoading = false;
    // String? _errorMessage;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on tap outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Edit Service Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.indigoAccent,
                      fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // if (_isLoading)
                    //   Center(child: CircularProgressIndicator()),
                    //
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(_errorMessage!,
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.red,
                                fontSize: 10)),
                      ),

                    GestureDetector(
                      onTap: () async {
                        XFile? selectedImage = await imagePicker.pickImage(
                            source: ImageSource.gallery);
                        if (selectedImage != null) {
                          setState(() {
                            profilePic = File(selectedImage.path);
                            _errorMessage = null;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            profilePic != null ? FileImage(profilePic!) : null,
                        child: profilePic == null
                            ? Icon(FontAwesomeIcons.camera, size: 50)
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Service Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      items: categoryItems,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategoryId = newValue;
                          selectedSubcategoryId = null; // Reset subcategory
                          fetchRelatedData('Subcategory', 'categoryId',
                              newValue!, subcategoryItems);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Subcategory Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedSubcategoryId,
                      items: subcategoryItems,
                      onChanged: (newValue) {
                        setState(() {
                          selectedSubcategoryId = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Subcategory',
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Province Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedProvinceId,
                      items: provinceItems,
                      onChanged: (newValue) {
                        setState(() {
                          selectedProvinceId = newValue;
                          selectedCityId = null; // Reset city
                          fetchRelatedData(
                              'City', 'provinceId', newValue!, cityItems);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Province',
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    SizedBox(height: 10),
                    // City Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCityId,
                      items: cityItems,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCityId = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'City',
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Service Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedServiceTypeId,
                      items: serviceTypeItems,
                      onChanged: (newValue) {
                        setState(() {
                          selectedServiceTypeId = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Service Type',
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Wage Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedWageTypeId,
                      items: wageTypeItems,
                      onChanged: (newValue) {
                        setState(() {
                          selectedWageTypeId = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Wage Type',
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: areaController,
                      decoration: InputDecoration(
                        labelText: 'Area',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: durationController,
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: discountController,
                      decoration: InputDecoration(
                        labelText: 'Discount %',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (!_isLoading)
                  TextButton(
                    child: Text('Cancel', style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                if (!_isLoading)
                  TextButton(
                    child: Text('Save', style: TextStyle(color: Colors.green)),
                    onPressed: () {
                      setState(() {
                        // Update the local state of the dialog to trigger re-render
                        if (!validateFields()) {
                          // The error message is updated inside validateFields()
                        } else {
                          _updateData().then((_) => Navigator.of(context)
                              .pop()); // Close the dialog on successful update
                        }
                        Future.delayed(Duration(seconds: 3), () {
                          setState(() {
                            _errorMessage = null;
                          }); // Reset the error message after 2 to 3 seconds
                        });
                      });
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Service Details",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      backgroundColor: Colors.teal,

      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.edit),
      //     onPressed: _showEditDialog, // Open edit dialog on edit button press
      //   ),
      //   IconButton(
      //     icon: Icon(Icons.delete),
      //     onPressed: () {
      //       showDialog(
      //         context: context,
      //         builder: (BuildContext context) {
      //           return AlertDialog(
      //             title: Text("Confirm Delete"),
      //             content: Text("Are you sure you want to delete this service?"),
      //             actions: [
      //               TextButton(
      //                 child: Text("Cancel"),
      //                 onPressed: () => Navigator.of(context).pop(),
      //               ),
      //               TextButton(
      //                 child: Text("Delete"),
      //                 onPressed: () async {
      //                   Navigator.of(context).pop();
      //                   await FirebaseFirestore.instance.collection('service').doc(widget.service.id).delete();
      //                   Navigator.of(context).pop();
      //                 },
      //               ),
      //             ],
      //           );
      //         },
      //       );
      //     },
      //   ),
      // ],
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.service.get('ImageUrl') != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.service.get('ImageUrl'),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.image_not_supported, size: 200),
            SizedBox(height: 20),
            uihelper.detailCard("Service Name",
                widget.service.get('ServiceName') ?? 'Not provided'),
            uihelper.detailCard(
                "Category", widget.service.get('Category') ?? 'Not provided'),
            uihelper.detailCard(
                "Price", widget.service.get('Price') ?? 'Not provided'),
            uihelper.detailCard("Service Type",
                widget.service.get('ServiceType') ?? 'Not provided'),
            uihelper.detailCard(
                "Discount", "${widget.service.get('Discount') ?? '0'}%"),
            uihelper.detailCard("Subcategory",
                widget.service.get('Subcategory') ?? 'Not provided'),
            uihelper.detailCard(
                "Wage Type", widget.service.get('WageType') ?? 'Not provided'),
            uihelper.detailCard(
                "Time Slot", widget.service.get('Duration') ?? 'Not provided'),
            uihelper.detailCard(
                "Province", widget.service.get('Province') ?? 'Not provided'),
            uihelper.detailCard(
                "City", widget.service.get('City') ?? 'Not provided'),
            uihelper.detailCard(
                "Area", widget.service.get('Area') ?? 'Not provided'),
            uihelper.detailCard("Description",
                widget.service.get('Description') ?? 'Not provided',
                lastItem: true),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                uihelper.actionButton('Delete', Colors.red,
                    Icons.dangerous_outlined, _showDeleteConfirmation),
                uihelper.actionButton(
                    'Edit', Colors.blue, Icons.edit, _showEditConfirmation),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
