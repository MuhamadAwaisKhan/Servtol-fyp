import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/subcategoryadd.dart'; // Make sure this file exists and correctly implements adding a subcategory
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class SubcategoryScreen extends StatefulWidget {
  const SubcategoryScreen({Key? key}) : super(key: key);

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<DropdownMenuItem<String>> categoryItems = [];
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot>? subcategoriesStream;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    subcategoriesStream = _db.collection('Subcategory')
        .orderBy('Name', descending: false) // Fetch data in ascending order by name

        .snapshots();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchCategories() async {
    try {
      var categoriesSnapshot = await _db.collection('Category').get();
      var items = categoriesSnapshot.docs
          .map((doc) => DropdownMenuItem<String>(
                value: doc.id,
                child: Text(doc.data()['Name'] ?? 'Unnamed Category'),
              ))
          .toList();
      setState(() {
        categoryItems = items;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void _onSearchChanged() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        subcategoriesStream = _db
            .collection('Subcategory')
            .where('Name', isGreaterThanOrEqualTo: searchController.text)
            .where('Name',
                isLessThanOrEqualTo: searchController.text + '\uf8ff')
            .snapshots();
      });
    } else {
      setState(() {
        subcategoriesStream = _db.collection('Subcategory').snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Subcategories",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.heading)),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Search Subcategory',
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                        child: Icon(Icons.clear, color: Colors.grey),
                        onTap: () {
                          searchController.clear();
                          setState(() {}); // Refresh the search
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild with every change
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: subcategoriesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Something went wrong');
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),

                  ));
                final data = snapshot.requireData;
                return ListView.separated(
                  itemCount: data.size,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    var subcategory = data.docs[index];
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.lightBlueAccent
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${index + 1}',
                              style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(subcategory['Name'],
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: AppColors.customButton),
                              onPressed: () => _showEditDialog(
                                  context,
                                  subcategory.id,
                                  subcategory['Name'],
                                  subcategory['categoryId']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteServiceType(subcategory.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => SubcategoryAddScreen())),
        label: Text('Add Subcategory', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: AppColors.secondaryColor),
        backgroundColor: AppColors.customButton,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _deleteServiceType(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text(
                'Confirm Delete',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this subcategory ? This action cannot be undone.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                _db.collection('Subcategory').doc(id).delete(); // Perform delete
                Navigator.of(context).pop(); // Close the dialog after delete
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditDialog(BuildContext context, String subcategoryId, String currentName, String currentCategoryId) {
    TextEditingController nameController = TextEditingController(text: currentName);
    String? selectedCategoryId = currentCategoryId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 28),
              SizedBox(width: 8),
              Text(
                'Edit Subcategory',
                style: TextStyle(fontFamily: 'Poppins',                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Subcategory Name',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                onChanged: (newValue) {
                  selectedCategoryId = newValue;
                },
                items: categoryItems,
                itemHeight: null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select Category',

                  labelStyle: TextStyle(color: Colors.blueAccent,                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () async {
                if (selectedCategoryId == null) {
                  print('Category ID is null');
                  return;
                }

                // Show confirmation dialog before saving
                bool confirmSave = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Confirm Save',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      content: Text(
                        'Are you sure you want to save these changes?',
                        style: TextStyle(fontFamily: 'Poppins', color: Colors.black87),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: Text('Yes', style: TextStyle(color: Colors.green, fontFamily: 'Poppins')),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                ) ?? false;

                if (confirmSave) {
                  _updateSubcategory(subcategoryId, nameController.text, selectedCategoryId!);
                  Navigator.pop(context); // Close the main dialog after saving
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.green, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }


  void _updateSubcategory(
      String subcategoryId, String newName, String newCategoryId) {
    _db
        .collection('Subcategory')
        .doc(subcategoryId)
        .update({
          'Name': newName,
          'categoryId': newCategoryId,
        })
        .then((_) => print('Subcategory updated successfully'))
        .catchError((e) => print('Error updating subcategory: $e'));
  }
}
