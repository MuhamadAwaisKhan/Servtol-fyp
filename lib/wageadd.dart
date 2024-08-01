import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class AddWageTypeScreen extends StatefulWidget {
  @override
  _AddWageTypeScreenState createState() => _AddWageTypeScreenState();
}

class _AddWageTypeScreenState extends State<AddWageTypeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool _isLoading = false;

    Future<void> _addWageType() async {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid wage type name')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('wageTypes').add({
          'Name': _nameController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wage type added successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add wage type: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Wage Type",
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
        ? Center(child: CircularProgressIndicator())
        : Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    uihelper.CustomTextField(_nameController, "Enter wage type name", Icons.warehouse, false),
    SizedBox(height: 20),
    uihelper.CustomButton(() {
    _addWageType();
    }, "Save", 50, 170),
    ],
    ),
    ),

    );
  }




}
