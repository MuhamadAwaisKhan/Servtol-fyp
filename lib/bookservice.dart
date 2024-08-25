import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/couponcustomer.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class BookServiceScreen extends StatefulWidget {
  final DocumentSnapshot service;

  const BookServiceScreen({Key? key, required this.service}) : super(key: key);

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int quantity = 1;
  TextEditingController addressController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  bool isRemoteService = false;
  String? couponId; // To store the selected coupon ID

  double taxRate = 0.05; // Default tax rate of 5%
  double discountedTotal = 0;
  bool isCouponApplied = false;
  double discountPercent = 0.0; // Discount percentage

  double get price {
    var data = widget.service.data() as Map<String, dynamic>;
    return double.tryParse(data['Price'].toString()) ?? 26.00;
  }

  double get subtotal => price * quantity;

  double get tax => (subtotal * taxRate) / 100;

  double get totalWithoutDiscount => subtotal + tax;

  double get total =>
      totalWithoutDiscount - (totalWithoutDiscount * discountPercent / 100);

  @override
  void initState() {
    super.initState();
    fetchTaxRate();
    determineServiceType();
  }

  @override
  void dispose() {
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void fetchTaxRate() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('taxes')
          .where('name', isEqualTo: 'ServiceTax')
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var fetchedTaxRate = double.tryParse(
                querySnapshot.docs.first.data()['rate'].toString()) ??
            0.05;
        setState(() {
          taxRate = fetchedTaxRate;
        });
      }
    } catch (e) {
      print('Error fetching tax rate: $e');
    }
  }

  void determineServiceType() {
    Map<String, dynamic> serviceData =
        widget.service.data() as Map<String, dynamic>;
    String serviceType = serviceData['ServiceType'] ?? 'In-Person';
    setState(() {
      isRemoteService = serviceType == 'Remote';
    });
  }

  void applyCoupon() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ApplyCouponScreen(
          originalTotal: total, // Total before discount
        ),
      ),
    );

    if (result != null &&
        result.containsKey('discountedTotal') &&
        result.containsKey('couponId')) {
      setState(() {
        discountedTotal = result['discountedTotal'];
        couponId = result['couponId'];
        isCouponApplied =
            true; // Ensure this flag is true only if the coupon is successfully applied
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to apply coupon or coupon was not selected.')));
    }
  }

  Future<void> saveBooking() async {
    if (!mounted) return;

    if (!isCouponApplied || couponId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please apply a coupon first.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (selectedDate == null ||
        selectedTime == null ||
        descriptionController.text.isEmpty ||
        (!isRemoteService && addressController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all required fields'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    String formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    try {
      var user = FirebaseAuth.instance.currentUser;
      var currentUserId = user?.uid ?? 'no-user-id';

      DocumentReference counterRef =
          FirebaseFirestore.instance.collection('counters').doc('bookingIds');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot counterSnapshot = await transaction.get(counterRef);

        // Properly cast the data
        Map<String, dynamic> counterData =
            counterSnapshot.data() as Map<String, dynamic>? ?? {};

        int lastId = counterData['current'] as int? ??
            0; // Now this should work without error
        int newId = lastId + 1;
        String formattedBookingId = newId.toString().padLeft(2, '0');

        // Update the counter document
        transaction.set(
            counterRef, {'current': newId}, SetOptions(merge: true));

        Map<String, dynamic> bookingData = {
          'serviceId': widget.service.id,
          'customerId': currentUserId,
          'providerId': widget.service['providerId'],
          'date': formattedDate,
          'time': selectedTime?.format(context),
          'quantity': quantity,
          'description': descriptionController.text,
          'total': total,
          'status': 'pending',
          'bookingId': formattedBookingId,
          'couponId': couponId,
          'address': isRemoteService ? 'Remote' : addressController.text,
        };

        // Set the new booking data
        transaction.set(
            FirebaseFirestore.instance
                .collection('bookings')
                .doc(formattedBookingId),
            bookingData);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Booking saved successfully.'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      print("Error saving booking: $e");
      print("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to book service: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
      recalculateTotal();
    });
  }

  void decrementQuantity() {
    setState(() {
      quantity = max(1, quantity - 1);
      recalculateTotal();
    });
  }

  void recalculateTotal() {
    discountedTotal = (subtotal + tax) * (1 - discountPercent);
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var serviceData = widget.service.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book Service",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Services',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Poppins',
              )),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Text('Service Details', style: TextStyle(
        //       fontSize: 24, fontWeight: FontWeight.bold)),
        // ),
        // ListTile(
        //   title: Text(serviceData['ServiceName'] ?? 'No Service Name'),
        //   subtitle: Text('Duration: ${serviceData['Duration']}'),
        //   trailing: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       IconButton(
        //           icon: Icon(Icons.remove), onPressed: decrementQuantity),
        //       Text('$quantity'),
        //       IconButton(
        //           icon: Icon(Icons.add), onPressed: incrementQuantity),
        //     ],
        //   ),
        // ),
        Card(
          color: Colors.grey[850],
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: FadeInImage.assetNetwork(
              placeholder: 'assets/placeholder.png',
              // Local asset placeholder image
              image: serviceData['ImageUrl'] ??
                  'https://example.com/default_image.jpg',
              fit: BoxFit.cover,
              width: 48,
              height: 48,
              imageErrorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, color: Colors.white);
              },
            ),
            title: Text(serviceData['ServiceName'] ?? 'No Service Name',
                style: TextStyle(color: Colors.white)),
            subtitle: Text(serviceData['Duration'] ?? 'No Duration',
                style: TextStyle(color: Colors.grey[400])),
            trailing: Container(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white),
                    onPressed: decrementQuantity,
                  ),
                  Text('$quantity',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: incrementQuantity,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Description ',
              style: TextStyle(
                  color: Colors.black, fontFamily: 'Poppins', fontSize: 20)),
        ),

        uihelper.customDescriptionField1(
            descriptionController, "Enter Description"),

        if (!isRemoteService)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Address ',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 20)),
              ),
              uihelper.customDescriptionField1(
                  addressController, "Enter Address"),
              SizedBox(height: 20),
            ],
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Booking Date & Slot ',
              style: TextStyle(
                  color: Colors.black, fontFamily: 'Poppins', fontSize: 20)),
        ),
        if (isLoading) Center(child: LinearProgressIndicator()),

        Container(
          width: 200,
          height: 60,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: () => _selectDate(context),
            child: Text(selectedDate == null
                ? 'Select Date'
                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
          ),
        ),
        Container(
          width: 200,
          height: 60,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: () => _selectTime(context),
            child: Text(selectedTime == null
                ? 'Select Time'
                : '${selectedTime!.format(context)}'),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apply Coupon',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.local_offer, color: Colors.white),
                label: Text('Apply', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplyCouponScreen(
                        originalTotal: total,
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      discountedTotal = result['discountedTotal'];
                      couponId = result['couponId'];
                      isCouponApplied =
                          true; // Assuming you maintain such a flag
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurpleAccent)),
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Price'),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors
                              .black, // Make sure to set a color for TextSpan
                        ),
                        children: [
                          TextSpan(
                              text:
                                  '\$${price.toStringAsFixed(0)} x $quantity = '),
                          TextSpan(
                            text: '\$${(price * quantity).toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal'),
                    Text('\$${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tax (${(taxRate).toStringAsFixed(1)}%)',
                        style: TextStyle(color: Colors.redAccent)),
                    Text('\$${tax.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
                Divider(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text('Total',
                //         style: TextStyle(fontWeight: FontWeight.bold)),
                //     Text('\$${total.toStringAsFixed(2)}',
                //         style: TextStyle(fontWeight: FontWeight.bold)),
                //   ],
                // ),

                if (isCouponApplied)
                  if (isCouponApplied)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount', style: TextStyle(color: Colors.green)),
                        Text(
                            '-\$${(total - discountedTotal).toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green)),
                      ],
                    ),
                Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        '\$${(isCouponApplied ? discountedTotal : total).toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              saveBooking();
            },
            child: Text('Confirm Booking'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple,
            ),
          ),
        )
      ])),
    );
  }
}
