import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

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

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 28),
              SizedBox(width: 10),
              Text(
                'Edit Coupon',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                uihelper.CustomTextField(
                    context, _editCodeController, "Code", Icons.code, false),
                uihelper.CustomNumberField(context, _editDiscountController,
                    "Discount", Icons.percent, false),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
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
                        style: TextStyle(
                            color: Colors.blue, fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: Colors.pink, fontFamily: 'Poppins')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update',
                  style: TextStyle(color: Colors.blue, fontFamily: 'Poppins')),
              onPressed: () async {
                if (_editSelectedDate == null) {
                  print('No date selected.');
                  return;
                }
                // Show confirmation dialog before updating
                bool confirmUpdate = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange, size: 28),
                              SizedBox(width: 10),
                              Text(
                                'Confirm Update',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          content: Text(
                            'Are you sure you want to save these changes?',
                            style: TextStyle(
                                fontFamily: 'Poppins', color: Colors.black87),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('No',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Poppins')),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: Text('Yes',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: 'Poppins')),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;

                if (confirmUpdate) {
                  String formattedDate =
                      "${_editSelectedDate!.year.toString()}-${_editSelectedDate!.month.toString().padLeft(2, '0')}-${_editSelectedDate!.day.toString().padLeft(2, '0')}";
                  await doc.reference.update({
                    'code': _editCodeController.text,
                    'discount': _editDiscountController.text,
                    'expiryDate': formattedDate,
                  });
                  Navigator.of(context).pop(); // Close the edit dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, DocumentSnapshot doc) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text(
                'Delete Coupon',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this coupon? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                doc.reference.delete();
                Navigator.of(context).pop();
              },
            ),
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
    if (_codeController.text.isEmpty ||
        _discountController.text.isEmpty ||
        selectedDate == null) {
      print('Please fill in all fields and select a date.');
      return;
    }

    String formattedDate =
        "${selectedDate!.year.toString()}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    try {
      DocumentReference ref =
          await FirebaseFirestore.instance.collection('coupons').add({
        'code': _codeController.text,
        'discount': _discountController.text,
        'expiryDate': formattedDate,
      });

      await ref.update({'couponId': ref.id});

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
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: AppColors.heading,
              fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          uihelper.CustomTextField(
              context, _codeController, "Code", Icons.discount, false),
          uihelper.CustomNumberField(context, _discountController, "Discount",
              Icons.numbers_sharp, false),
          Container(
            width: 360,
            height: 60,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: () => _selectDate(context),
              child: Text(selectedDate == null
                  ? 'Expiry Date (DD/MM/YYYY)'
                  : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'),
            ),
          ),
          SizedBox(height: 10),
          uihelper.CustomButton(() {
            addCoupon();
          }, 'Add Coupon', 40, 150),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coupons')
                  .orderBy('code',
                      descending:
                          false) // Fetch data in ascending order by name
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Colors.blue.shade50,
                        child: ListTile(
                          title: Text(doc['code'],
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Discount: ${doc['discount']}%',
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 14)),
                              Text('Valid until: ${doc['expiryDate']}',
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 14)),
                            ],
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
                                onPressed: () => _confirmDelete(context, doc),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
