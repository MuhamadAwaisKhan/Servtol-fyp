import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class timestampadd extends StatefulWidget {
  const timestampadd({super.key});

  @override
  State<timestampadd> createState() => _timestampaddState();
}

class _timestampaddState extends State<timestampadd> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(); // Controller for duration input
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Timestamp",
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
          ? Center(child: CircularProgressIndicator()) // Show loader while adding data
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset(
              'assets/images/timestamp.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 20),
            // Name input field

            // Duration input field (in minutes)
            uihelper.CustomTextField(
              context,
              _durationController,
              "Enter Duration (in minutes)",
              Icons.access_time,
              false,
               // Ensure numeric input
            ),
            SizedBox(height: 20),
            // Save button
            uihelper.CustomButton(
                  () {
                if (!_isLoading) {
                  _addServiceType(); // Call to add timestamp with duration
                }
              },
              "Save",
              50,
              170,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addServiceType() async {
    if ( _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please Enter duration')),
      );
      return;
    }

    // Ensure the duration is a valid number

    if (_durationController == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid duration (positive number)')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('timestamp').add({
        // 'Name': _nameController.text.trim(),
        'Name': _durationController, // Add duration field
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timestamp added successfully')),
      );
      Navigator.pop(context); // Go back to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add timestamp: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
