import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/categoryadd.dart'; // Ensure this path is correct
import 'package:servtol/util/AppColors.dart';

class categoryscreen extends StatefulWidget {
  const categoryscreen({super.key});

  @override
  State<categoryscreen> createState() => _categoryscreenState();
}

class _categoryscreenState extends State<categoryscreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot>? categoriesStream;

  @override
  void initState() {
    super.initState();
    categoriesStream = _db.collection('Category').snapshots();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        categoriesStream = _db.collection('Category')
            .where('Name', isGreaterThanOrEqualTo: searchController.text)
            .where('Name', isLessThanOrEqualTo: searchController.text + '\uf8ff')
            .snapshots();
      });
    } else {
      setState(() {
        categoriesStream = _db.collection('Category').snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Category",
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Search Provinces',
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                  child: Icon(Icons.clear, color: Colors.grey),
                  onTap: () {
                    searchController.clear();
                    _onSearchChanged(); // Refresh the search
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
                _onSearchChanged(); // Trigger rebuild with every change
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: categoriesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Something went wrong');
                if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
                final data = snapshot.requireData;
                return ListView.separated(
                  itemCount: data.size,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    var category = data.docs[index];
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
                        title: Text(category['Name'], textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(context, category.id, category['Name']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(category.id),
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
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => categoryadd()));
        },
        label: Text('Add Category', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: AppColors.secondaryColor),
        backgroundColor: AppColors.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _deleteCategory(String id) {
    _db.collection('Category').doc(id).delete();
  }

  void _showEditDialog(BuildContext context, String id, String currentName) {
    TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Enter New Category Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: Colors.green)),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _updateCategory(id, nameController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateCategory(String id, String newName) {
    _db.collection('Category').doc(id).update({'Name': newName});
  }
}
