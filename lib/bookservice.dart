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
  String? couponId;

  double taxRate = 0.05; // 5% default tax rate
  double bookingFee = 0.0; // Default booking fee
  double discountedTotal = 0;
  double discountPercent = 0.0; // Discount percentage

  // Calculate price from service data
  double get price {
    var data = widget.service.data() as Map<String, dynamic>;
    return double.tryParse(data['Price'].toString()) ?? 26.00;
  }

  // Calculate subtotal
  double get subtotal => price * quantity;

// Calculate tax on the subtotal including the booking fee
// Calculate tax on the subtotal including the booking fee
  double get tax => (subtotal + bookingFee) * taxRate / 100;

// Calculate total without discount
  double get totalWithoutDiscount => subtotal + tax;

// Calculate total with discount
  double get total => totalWithoutDiscount * (1 - discountPercent / 100);

  bool isCouponApplied = false;
  String? taxRateId;
  String? bookingFeeId;

  @override
  void initState() {
    super.initState();
    fetchTaxRate();
    fetchBookingFee();
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
          .collection('taxRates')
          .where('name', isEqualTo: 'ServiceTax')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        setState(() {
          taxRate = double.tryParse(doc['rate'].toString()) ?? 0.05;
          taxRateId = doc.id;
        });
        print('Fetched Tax Rate: ${taxRate}');
        print('Tax Rate Document ID: $taxRateId');
      } else {
        print('No documents found for ServiceTax.');
      }
    } catch (e) {
      print('Error fetching tax rate: $e');
    }
  }

  void fetchBookingFee() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('bookingFees')
          .where('name', isEqualTo: 'BookingFee')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        setState(() {
          bookingFee = double.tryParse(doc['rate'].toString()) ?? 0.0;
          bookingFeeId = doc.id;
        });
        print('Fetched Booking Fee: \$${bookingFee}');
        print('Booking Fee Document ID: $bookingFeeId');
      } else {
        print('No documents found for Bookingfee.');
      }
    } catch (e) {
      print('Error fetching booking fee: $e');
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

    // Validate coupon
    if (!isCouponApplied || couponId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please apply a coupon first.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Validate required fields
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
        try {
          // Get the current booking ID and update it
          DocumentSnapshot counterSnapshot = await transaction.get(counterRef);
          int lastId = (counterSnapshot.data() as Map<String, dynamic>? ?? {})['current'] as int? ?? 0;
          int newId = lastId + 1;
          String formattedBookingId = newId.toString().padLeft(2, '0');
          transaction.set(counterRef, {'current': newId}, SetOptions(merge: true));

          print("Booking ID: $formattedBookingId");

          // Determine the final total based on whether a coupon is applied
          double finalTotal = isCouponApplied ? discountedTotal : total;

          // Prepare booking data
          Map<String, dynamic> bookingData = {
            'serviceId': widget.service.id,
            'customerId': currentUserId,
            'providerId': widget.service['providerId'],
            'date': formattedDate,
            'time': selectedTime?.format(context),
            'quantity': quantity,
            'description': descriptionController.text,
            'total': finalTotal,
            'status': 'Pending',
            'paymentstatus': 'Pending',
            'statusHistory': [
              {
                'status': 'Pending',
                'timestamp': FieldValue.serverTimestamp(),
              }
            ],
            'bookingId': formattedBookingId,
            'couponId': couponId,
            'address': isRemoteService ? 'Remote' : addressController.text,
            'tax': tax,
            'taxRateId': taxRateId,
            'bookingFeeId': bookingFeeId,
            'ServiceName': widget.service['ServiceName'],
            'serviceNameLower': (widget.service['ServiceName'] ?? '').toString().toLowerCase(),
            'ImageUrl': widget.service['ImageUrl'],
          };

          print("Booking Data: $bookingData");

          // Save booking
          transaction.set(
            FirebaseFirestore.instance.collection('bookings').doc(formattedBookingId),
            bookingData,
          );

          print("Booking saved successfully.");

          // Add notification for the provider
          Map<String, dynamic> notificationData = {
            'providerId': widget.service['providerId'],
            'customerId': currentUserId,
            'bookingId': formattedBookingId,
            'message': 'You have a new booking.',
            'message1': 'You have booked a service',
            'date': formattedDate,
            'time': selectedTime?.format(context),
            'isRead': false,
            'isRead1': false,
            'status': 'Pending',
            'paymentstatus': 'Pending',
            'timestamp': FieldValue.serverTimestamp(),
          };

          transaction.set(
            FirebaseFirestore.instance.collection('bookingnotifications').doc(),
            notificationData,
          );

          print("Notification saved successfully.");
        } catch (bookingError) {
          print("Error saving booking or notification: $bookingError");
          throw bookingError; // Rethrow to be caught in the outer block
        }
      }).catchError((transactionError) {
        print('Transaction failed: $transactionError');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Transaction failed: $transactionError'),
          backgroundColor: Colors.red,
        ));
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Booking saved successfully.'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop();

    } catch (e, stackTrace) {
      print("Error during transaction: $e");
      print("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to book service: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
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
            border: Border.all(color: Colors.blue),
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
            border: Border.all(color: Colors.blue),
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
            color: Colors.lightBlue[200],
                // .withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apply Coupon',
                style: TextStyle(
                  color: Colors.white,
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
                color:Colors.brown[150],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue)),
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
                                  '\$${price.toStringAsFixed(2)} x $quantity = '),
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
                    Text('Tax', style: TextStyle(color: Colors.redAccent)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.attach_money,
                                            color: Colors.green),
                                        title: Text('Booking Fee'),
                                        subtitle: Text(
                                            '\$${bookingFee.toStringAsFixed(2)}'),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.percent,
                                            color: Colors.blue),
                                        title: Text('Service Tax'),
                                        subtitle: Text(
                                            '${(taxRate).toStringAsFixed(2)}%'),
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Close the modal
                                        },
                                        child: Text('Close'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.indigoAccent,
                                            foregroundColor: Colors.white),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.info_outline_rounded),
                        ),
                        Text('\$${tax.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
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
                  if (isCouponApplied) ...[
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
                  ],

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
              backgroundColor: AppColors.customButton,
            ),
          ),
        )
      ])),
    );
  }
}
