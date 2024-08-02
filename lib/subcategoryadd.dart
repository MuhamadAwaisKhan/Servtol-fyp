import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class SubcategoryAddScreen extends StatefulWidget {
  const SubcategoryAddScreen({super.key});

  @override
  State<SubcategoryAddScreen> createState() => _SubcategoryAddScreenState();
}

class _SubcategoryAddScreenState extends State<SubcategoryAddScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategory;
  List<DropdownMenuItem<String>> _categoryDropdownItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    var categoriesSnapshot =
    await FirebaseFirestore.instance.collection('Category').get();
    var items = categoriesSnapshot.docs.map((doc) {
      return DropdownMenuItem<String>(
        value: doc.id,
        child: Text(doc.data()['Name']),
      );
    }).toList();

    setState(() {
      _categoryDropdownItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Subcategory",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.heading)),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset('assets/images/subcategory.json',
                width: 200, height: 200, fit: BoxFit.fill),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) =>
                    setState(() => _selectedCategory = value),
                items: _categoryDropdownItems,
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            uihelper.CustomTextField(_nameController, "Enter Subcategory Name",
                Icons.category, false),

            SizedBox(height: 20),
            uihelper.CustomButton(() {
              if (!_isLoading) {
                _addSubcategory();
              }
            }, "Save", 50, 170),
          ],
        ),
      ),
    );
  }

  Future<void> _addSubcategory() async {
    if (_nameController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields correctly')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('Subcategory').add({
        'Name': _nameController.text.trim(),
        'categoryId': _selectedCategory,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subcategory added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add subcategory: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
