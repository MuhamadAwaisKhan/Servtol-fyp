import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class CityAdd extends StatefulWidget {
  const CityAdd({super.key});

  @override
  State<CityAdd> createState() => _CityAddState();
}

class _CityAddState extends State<CityAdd> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedProvince;
  List<DropdownMenuItem<String>> _provinceDropdownItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    var provincesSnapshot =
        await FirebaseFirestore.instance.collection('Province').get();
    var items = provincesSnapshot.docs.map((doc) {
      return DropdownMenuItem<String>(
        value: doc.id, // Assuming document ID is used as the value
        child: Text(doc.data()['Name']),
      );
    }).toList();

    setState(() {
      _provinceDropdownItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add City",
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
                  Lottie.asset('assets/images/city.json',
                      width: 200, height: 200, fit: BoxFit.fill),
                  SizedBox(height: 40),
                 Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
                   child: DropdownButtonFormField<String>(
                    value: _selectedProvince,
                    onChanged: (value) =>
                        setState(() => _selectedProvince = value),
                    items: _provinceDropdownItems,
                    decoration: InputDecoration(
                      labelText: 'Select Province',
                      labelStyle: TextStyle(color: Colors.blue,fontFamily: 'Poppins'),
                      suffixIcon: Icon(Icons.ac_unit_rounded),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        // Blue border when focused
                        borderRadius: BorderRadius.circular(25),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        // Grey border when not focused
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                 ),

                  uihelper.CustomTextField(context,_nameController, "Enter City Name",
                      Icons.location_city, false),

                  SizedBox(height: 20),
                  uihelper.CustomButton(() {
                    if (!_isLoading) {
                      _addCity();
                    }
                  }, "Save", 50, 170),
                ],
              ),
            ),
    );
  }

  Future<void> _addCity() async {
    if (_nameController.text.isEmpty || _selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields correctly')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('City').add({
        'Name': _nameController.text.trim(),
        'provinceId': _selectedProvince,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('City added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add city: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
