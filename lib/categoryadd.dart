import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
class categoryadd extends StatefulWidget {
  const categoryadd({super.key});

  @override
  State<categoryadd> createState() => _categoryaddState();
}

class _categoryaddState extends State<categoryadd> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;  // Initial state is not loading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Category",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())  // Show loader while adding data
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset('assets/images/category1.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 20),
            uihelper.CustomTextField(context,_nameController, "Enter Category Name", Icons.warehouse, false),
            SizedBox(height: 20),
            uihelper.CustomButton(() {
              if (!_isLoading) {  // Prevent multiple submissions
                _addServiceType();
              }
            }, "Save", 50, 170),
          ],
        ),
      ),
    );
  }

  Future<void> _addServiceType() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please Enter a valid Category name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('Category').add({
        'Name': _nameController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category  added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add Category: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}