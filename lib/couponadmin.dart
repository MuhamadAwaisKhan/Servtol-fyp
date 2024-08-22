import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'dart:core';

class AdminCouponScreen extends StatefulWidget {
  @override
  _AdminCouponScreenState createState() => _AdminCouponScreenState();
}

class _AdminCouponScreenState extends State<AdminCouponScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  DateTime? selectedDate;

  Future<void> _editCoupon(BuildContext context, DocumentSnapshot doc) async {
    TextEditingController _editCodeController =
        TextEditingController(text: doc['code']);
    TextEditingController _editDiscountController =
        TextEditingController(text: doc['discount']);
    DateTime? _editSelectedDate = DateTime.tryParse(doc['expiryDate']);

    // Show the dialog
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Coupon'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                uihelper.CustomTextField(
                    _editCodeController, "Code", Icons.code, false),
                uihelper.CustomNumberField(
                    _editDiscountController, "Discount", Icons.percent, false),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _editSelectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _editSelectedDate) {
                        setState(() {
                          _editSelectedDate = picked;
                        });
                      }
                    },
                    child: Text(
                      _editSelectedDate == null
                          ? 'Select Date'
                          : '${_editSelectedDate!.day.toString().padLeft(2, '0')}/${_editSelectedDate!.month.toString().padLeft(2, '0')}/${_editSelectedDate!.year}',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.pink),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Update',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () async {
                if (_editSelectedDate == null) {
                  print('No date selected.');
                  return;
                }
                String formattedDate =
                    "${_editSelectedDate!.year.toString()}-${_editSelectedDate!.month.toString().padLeft(2, '0')}-${_editSelectedDate!.day.toString().padLeft(2, '0')}";
                await doc.reference.update({
                  'code': _editCodeController.text,
                  'discount': _editDiscountController.text,
                  'expiryDate': formattedDate,
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> addCoupon() async {
    if (_codeController.text.isEmpty || _discountController.text.isEmpty || selectedDate == null) {
      print('Please fill in all fields and select a date.');
      return;
    }

    // Formatting the date to 'YYYY-MM-DD' format for storage
    String formattedDate =
        "${selectedDate!.year.toString()}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    try {
      // Create the document and get the reference
      DocumentReference ref = await FirebaseFirestore.instance.collection('coupons').add({
        'code': _codeController.text,
        'discount': _discountController.text,
        'expiryDate': formattedDate,
      });

      // Optionally update the document with its own ID if needed
      await ref.update({'couponId': ref.id});

      // Clear the controllers and reset selectedDate after successful Firestore operation
      setState(() {
        _codeController.clear();
        _discountController.clear();
        selectedDate = null;
      });

      print('Coupon added successfully with ID: ${ref.id}');
    } catch (e) {
      print('Error adding coupon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Coupons",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          uihelper.CustomTextField(
              _codeController, "Code", Icons.discount, false),
          uihelper.CustomNumberField(
              _discountController, "Discount", Icons.numbers_sharp, false),
          Container(
            width: 360,
            height: 60,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: () => _selectDate(context),
              child: Text(selectedDate == null
                  ? 'Expiry Date (DD/MM/YYYY)'
                  : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'),
            ),
          ),
          SizedBox(height:10,),
          uihelper.CustomButton((){
            addCoupon();
          }, 'Add Coupon', 40, 150),
          SizedBox(height:10,),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // Using ListView.builder for building list items
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(doc['code'], style: TextStyle(fontFamily: 'Poppins')),
                          subtitle: Text(
                            'Discount: ${doc['discount']}% Valid until: ${doc['expiryDate']}',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.indigo),
                                onPressed: () => _editCoupon(context, doc),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => doc.reference.delete(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

        ],
      ),
    );
  }
}
