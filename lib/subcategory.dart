import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/subcategoryadd.dart';  // Make sure this file exists and correctly implements adding a subcategory
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
    subcategoriesStream = _db.collection('Subcategory').snapshots();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchCategories() async {
    try {
      var categoriesSnapshot = await _db.collection('Category').get();
      var items = categoriesSnapshot.docs.map((doc) => DropdownMenuItem<String>(
        value: doc.id,
        child: Text(doc.data()['Name'] ?? 'Unnamed Category'),
      )).toList();
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
        subcategoriesStream = _db.collection('Subcategory')
            .where('Name', isGreaterThanOrEqualTo: searchController.text)
            .where('Name', isLessThanOrEqualTo: searchController.text + '\uf8ff')
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
        title: Text("Manage Subcategories", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.heading)),
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
                labelText: 'Search Services',
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
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                final data = snapshot.requireData;
                return ListView.separated(
                  itemCount: data.size,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    var subcategory = data.docs[index];
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(subcategory['Name'], style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(context, subcategory.id, subcategory['Name'], subcategory['categoryId']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSubcategory(subcategory.id),
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
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubcategoryAddScreen())),
        label: Text('Add Subcategory', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: AppColors.secondaryColor),
        backgroundColor: AppColors.primaryColor,
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

  void _deleteSubcategory(String id) {
    _db.collection('Subcategory').doc(id).delete().then((_) => print('Subcategory deleted successfully')).catchError((e) => print('Error deleting subcategory: $e'));
  }

  void _showEditDialog(BuildContext context, String subcategoryId, String currentName, String currentCategoryId) {
    TextEditingController nameController = TextEditingController(text: currentName);
    String? selectedCategoryId = currentCategoryId;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Subcategory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Subcategory Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                onChanged: (newValue) {
                  setState(() {
                    selectedCategoryId = newValue;
                  });
                },
                items: categoryItems,
                decoration: InputDecoration(labelText: 'Select Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (selectedCategoryId != null) {
                  _updateSubcategory(subcategoryId, nameController.text, selectedCategoryId!);
                  Navigator.pop(context);
                } else {
                  print('Category ID is null');
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _updateSubcategory(String subcategoryId, String newName, String newCategoryId) {
    _db.collection('Subcategory').doc(subcategoryId).update({
      'Name': newName,
      'categoryId': newCategoryId,
    }).then((_) => print('Subcategory updated successfully')).catchError((e) => print('Error updating subcategory: $e'));
  }
}
