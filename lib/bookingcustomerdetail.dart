import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/bookingcustomer.dart';
import 'package:servtol/util/AppColors.dart';

enum PaymentMethod { cash, card }

class BookingCustomerDetail extends StatefulWidget {
  final DocumentSnapshot bookings;

  const BookingCustomerDetail({Key? key, required this.bookings})
      : super(key: key);

  @override
  State<BookingCustomerDetail> createState() => _BookingCustomerDetailState();
}

class _BookingCustomerDetailState extends State<BookingCustomerDetail> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Declare these variables in the state class
  double taxRate = 0.05; // Default value
  double bookingFee = 0.0; // Default value

  @override
  void initState() {
    super.initState();
    fetchTaxRate();
    fetchBookingFee();
  }
  Future<void> updatePaymentNotificationStatus(
      String bookingId, String newPaymentStatus) async {
    try {
      // Find the payment notification document
      QuerySnapshot paymentNotificationSnapshot = await _firestore
          .collection('paymentnotification')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (paymentNotificationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot notificationDoc = paymentNotificationSnapshot.docs.first;

        // Update the payment notification status
        await _firestore
            .collection('paymentnotification')
            .doc(notificationDoc.id)
            .update({
          'paymentstatus': newPaymentStatus,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print('No payment notification found for booking ID: $bookingId');
      }
    } catch (e) {
      print('Error updating payment notification status: $e');
    }
  }
  void updateBookingStatus(String cancellationReason) async {
    try {
      String bookingId = widget.bookings.id;

      // 1. Update the booking status and include cancellation reason
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'Cancelled',
        'cancellationReason': cancellationReason,
        'timestamp': FieldValue.serverTimestamp(), // Add the reason
      });

      // 2. Find the corresponding notification
      QuerySnapshot notificationSnapshot = await _firestore
          .collection('notifications')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot notificationDoc = notificationSnapshot.docs.first;

        // 3. Update the notification with the reason (if provided)
        String providerMessage =
            'Your booking has been cancelled by the customer.';
        String customerMessage = 'You have cancelled the service booking.';

        // if (cancellationReason.isNotEmpty) {
        //   providerMessage += ' Reason: $cancellationReason';
        //   customerMessage += ' Reason: $cancellationReason';
        // }

        await _firestore
            .collection('notifications')
            .doc(notificationDoc.id)
            .update({
          'message': providerMessage,
          'message1': customerMessage,
          'status': 'Cancelled',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print('No notification found for booking ID: $bookingId');
      }

      // 4. Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking has been cancelled')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking')),
      );
    }
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
        });
        // print('Fetched Tax Rate: ${taxRate}');
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
        });
        // print('Fetched Booking Fee: \$${bookingFee}');
      } else {
        print('No documents found for BookingFee.');
      }
    } catch (e) {
      print('Error fetching booking fee: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchDocument(
      String collection, String documentId) async {
    try {
      var snapshot =
          await _firestore.collection(collection).doc(documentId).get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data();
      } else {
        print("Document not found in $collection with ID $documentId");
        return null;
      }
    } catch (e) {
      print("Failed to fetch document from $collection: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchBookingDetails() async {
    Map<String, dynamic> bookingData =
        widget.bookings.data() as Map<String, dynamic>;

    Map<String, dynamic> result = {
      'provider': {},
      'coupon': {},
      'service': {},
    };

    if (bookingData['providerId'] != null) {
      result['provider'] =
          await fetchDocument('provider', bookingData['providerId']);
    }
    if (bookingData['couponId'] != null) {
      result['coupon'] =
          await fetchDocument('coupons', bookingData['couponId']);
    }
    if (bookingData['serviceId'] != null) {
      result['service'] =
          await fetchDocument('service', bookingData['serviceId']);
    }

    return result;
  }

  void updateBookingStatus1(String cancellationReason) async {
    try {
      String bookingId = widget.bookings.id;

      // 1. Update the booking status and include cancellation reason
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'Cancelled',
        'cancellationReason': cancellationReason,
        'timestamp': FieldValue.serverTimestamp(), // Add the reason
      });

      // 2. Find the corresponding notification
      QuerySnapshot notificationSnapshot = await _firestore
          .collection('notifications')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot notificationDoc = notificationSnapshot.docs.first;

        // 3. Update the notification with the reason (if provided)
        String providerMessage =
            'Your booking has been cancelled by the customer.';
        String customerMessage = 'You have cancelled the service booking.';

        // if (cancellationReason.isNotEmpty) {
        //   providerMessage += ' Reason: $cancellationReason';
        //   customerMessage += ' Reason: $cancellationReason';
        // }

        await _firestore
            .collection('notifications')
            .doc(notificationDoc.id)
            .update({
          'message': providerMessage,
          'message1': customerMessage,
          'status': 'Cancelled',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print('No notification found for booking ID: $bookingId');
      }

      // 4. Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking has been cancelled')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors
            .deepOrange; // Darker orange that stands out on a light background.

      case 'Cancelled':
        return Colors
            .black54; // A dark grey to indicate a disabled or inactive state.

      case 'Rejected':
        return Colors
            .red[800]!; // A dark red to clearly indicate a negative status.

      case 'Accepted':
        return Colors
            .green[700]!; // A darker shade of green for better visibility.

      case 'In Progress':
        return Colors
            .indigo[700]!; // A deep indigo for a sense of ongoing work.

      case 'Waiting':
        return Colors.blueGrey[
            800]!; // Dark blue-grey to suggest a paused or waiting state.

      case 'Complete':
        return Colors.green[900]!;
      case 'Payment Pending':
        return Colors.deepPurple[
            900]!; // A dark green to represent finality and success.

      case 'On going':
        return Colors.blue[800]!;
      case 'In Process':
        return Colors.brown[800]!;

      case 'Ready to Service':
        return Colors.tealAccent[400]!;

      default:
        return Colors
            .grey[800]!; // Dark grey for any unknown or undefined statuses.
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;

      case 'Paid by Card':
        return Colors.green;
      case 'OnCash':
        return Colors.teal;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String generateUniquePaymentId() {
    // ... your logic to generate a unique payment ID
    // For now, let's use a simple combination of timestamp and random number
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int randomNumber =
        Random().nextInt(10000); // Generate a random number between 0 and 9999
    return 'P$timestamp\_$randomNumber';
  }

  String generateUniqueTransactionId() {
    // ... your logic to generate a unique transaction ID
    // Similar to payment ID, let's use timestamp and random number
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int randomNumber = Random().nextInt(10000);
    return 'TR_$timestamp\_$randomNumber';
  }

  // PaymentMethod? _selectedMethod = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(
                widget.bookings['status'] as String? ?? 'pending'),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.bookings['status'] as String? ?? 'Pending',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: AppColors.background,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Check Status",
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                  fontSize: 13),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchBookingDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error fetching booking details'));
          }
          var data = snapshot.data!;
          var bookingStatus = widget.bookings['status'] as String? ?? '';
          var paymentstatus = widget.bookings['paymentstatus'] as String? ?? '';
          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((bookingStatus == 'Accepted' ||
                              bookingStatus == 'In Process' ||
                              bookingStatus == 'Payment Pending') &&
                          paymentstatus == 'Pending') ...[
                        Column(
                          children: [
                            Text(
                              'Your booking request is accepted please select payment method for further processing',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            ElevatedButton(
                              onPressed: () {
                                PaymentMethod? _selectedMethod =
                                    null; // Declare _selectedMethod here

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Choose Payment Method',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                elevation: 5,
                                                child: ListTile(
                                                  leading: FaIcon(
                                                    FontAwesomeIcons
                                                        .moneyBillAlt,
                                                    color: Colors.green,
                                                  ),
                                                  title: Text(
                                                    'On Cash',
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  trailing:
                                                      Radio<PaymentMethod>(
                                                    value: PaymentMethod.cash,
                                                    groupValue: _selectedMethod,
                                                    onChanged:
                                                        (PaymentMethod? value) {
                                                      setState(() {
                                                        _selectedMethod =
                                                            value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                elevation: 5,
                                                child: ListTile(
                                                  leading: FaIcon(
                                                    FontAwesomeIcons.creditCard,
                                                    color: Colors.blue,
                                                  ),
                                                  title: Text(
                                                    'Card Payment',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  trailing:
                                                      Radio<PaymentMethod>(
                                                    value: PaymentMethod.card,
                                                    groupValue: _selectedMethod,
                                                    onChanged:
                                                        (PaymentMethod? value) {
                                                      setState(() {
                                                        _selectedMethod =
                                                            value!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();

                                                if (_selectedMethod != null) {
                                                  // Handle the selected payment method
                                                  print(
                                                      "Selected Payment Method: $_selectedMethod");

                                                  // 1. Get necessary data
                                                  String bookingId =
                                                      widget.bookings.id;
                                                  String customerId = widget
                                                      .bookings['customerId'];
                                                  String providerId = widget
                                                      .bookings['providerId'];
                                                  String notificationMessage;
                                                  String notificationMessage1;

                                                  if (_selectedMethod ==
                                                      PaymentMethod.cash) {
                                                    notificationMessage =
                                                        "Customer has selected On Cash as payment method";
                                                    notificationMessage1 =
                                                        "You have selected to pay On Cash";
                                                  } else if (_selectedMethod ==
                                                      PaymentMethod.card) {
                                                    notificationMessage =
                                                        "Customer has selected to pay by Card";
                                                    notificationMessage1 =
                                                        "You have selected to pay by Card";
                                                  } else {
                                                    // Handle the case where the payment method is not recognized
                                                    notificationMessage =
                                                        "Customer has selected an unknown payment method";
                                                    notificationMessage1 =
                                                        "You have selected an unknown payment method";
                                                  }
                                                  String paymentStatus =
                                                      _selectedMethod ==
                                                              PaymentMethod.cash
                                                          ? 'OnCash'
                                                          : 'Paid by Card';

                                                  // 2. Create or Update PaymentNotification
                                                  final paymentNotificationRef =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'paymentnotification')
                                                          .doc(bookingId);

                                                  paymentNotificationRef
                                                      .get()
                                                      .then((snapshot) async {
                                                    if (!snapshot.exists) {
                                                      // Create a new payment notification if it doesn't exist
                                                      await paymentNotificationRef
                                                          .set({
                                                        'providerId':
                                                            providerId,
                                                        'customerId':
                                                            customerId,
                                                        'bookingId': bookingId,
                                                        'message':
                                                            notificationMessage,
                                                        'message1':
                                                            notificationMessage1,
                                                        'isRead': false,
                                                        'isRead1': false,
                                                        'paymentstatus':
                                                            paymentStatus,
                                                        'timestamp': FieldValue
                                                            .serverTimestamp(),
                                                      });
                                                    } else {
                                                      // Update the existing payment notification if it exists
                                                      await paymentNotificationRef
                                                          .update({
                                                        'paymentstatus':
                                                        paymentStatus
                                                                .toString(),
                                                        // Or any other field you want to update
                                                        'timestamp': FieldValue
                                                            .serverTimestamp(),
                                                      });
                                                    }
                                                  });

                                                  // 3. Create Payment Document
                                                  final paymentRef =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'payments')
                                                          .doc();
                                                  paymentRef.set({
                                                    'bookingId': bookingId,
                                                    'customerId': customerId,
                                                    'providerId': providerId,
                                                    'paymentId':
                                                        generateUniquePaymentId(),
                                                    'transactionId':
                                                        generateUniqueTransactionId(),
                                                    'paymentstatus':
                                                        paymentStatus,
                                                  });

                                                  // 4. Update Booking Status in Firestore
                                                  FirebaseFirestore.instance
                                                      .collection('bookings')
                                                      .doc(bookingId)
                                                      .update({
                                                    'paymentstatus':
                                                        paymentStatus,
                                                    'status':
                                                        'Ready to Service',
                                                  }).then((_) {
                                                    Navigator.of(context).pop();
                                                    // Trigger a reload of the data after the update
                                                    setState(() {
                                                      RefreshProgressIndicator();
                                                    });

                                                    // Navigator.of(context).push(MaterialPageRoute(
                                                    //   builder: (context) => BookingCustomer(onBackPress:  ), // Replace with your actual TargetScreen widget
                                                    // ));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Payment selected, service is ready to begin')),
                                                    );
                                                  });
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Please select a payment method')),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                'Confirm',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueGrey,
                              ),
                              child: Text('Payment Methods'),
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            SizedBox(height: 10),
                          ],
                        ),
                      ],
                      if (bookingStatus == 'Cancelled') ...[
                        Column(
                          children: [
                            Text('Reason ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(height: 5),
                            Text(
                                '${widget.bookings['cancellationReason'] as String? ?? 'No Reason'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontFamily: 'Poppins',
                                )),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Status',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.bookings['paymentstatus'] as String? ?? 'No payments'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: _getPaymentStatusColor(
                                  widget.bookings['paymentstatus'] as String? ??
                                      'No payments'),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                      SizedBox(
                        height: 10,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Booking ID ',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              )),
                          Text('# ${widget.bookings.id}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      Text('${data['service']?['ServiceName'] ?? 'No Service'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // Aligns children across the main axis with space in between
                        children: [
                          // Column for Date and Time
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // Aligns the column's children to the start, matching your existing text alignment
                            children: [
                              Row(
                                children: [
                                  Text('Date:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text(
                                      ' ${widget.bookings['date'] as String? ?? 'No Date'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      )),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text('Time:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text(
                                      '${widget.bookings['time'] as String? ?? 'No time'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      )),
                                ],
                              ),
                            ],
                          ),
                          // Image in a ClipRect
                          ClipRect(
                            child: SizedBox(
                              height: 70, // Specifies the height of the image
                              width: 70, // Specifies the width of the image
                              child: Image.network(
                                data['service']['ImageUrl'] ??
                                    'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=',
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Text('Failed to load image'),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      Text('Booking Description:',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: 5),
                      Text(
                          '${widget.bookings['description'] as String? ?? 'No time'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.grey,
                          )),
                      SizedBox(height: 10),
                      Text('About Provider',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Card(
                        elevation: 4.0,
                        // Adds shadow under the card
                        margin: EdgeInsets.all(8.0),
                        // Adds margin around the card
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Rounded corners
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              data['provider']['ProfilePic'] ??
                                  'https://via.placeholder.com/150', // Ensure this URL points to a valid placeholder
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                '${data['provider']['FirstName'] ?? 'Unknown'} ${data['provider']['LastName'] ?? ''}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow
                                    .ellipsis, // Prevents text from overflowing
                              ),
                              IconButton(
                                onPressed: () {
                                  // Define what happens when the info button is pressed
                                },
                                icon: Icon(Icons.info),
                                tooltip:
                                    'More Info', // Tooltip text on long press
                              )
                            ],
                          ),
                          subtitle: Text(
                            "${data['provider']['Bio'] ?? 'No additional information'}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          onTap: () {
                            // Define what happens when you tap this ListTile
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Price Detail',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      // SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.deepPurpleAccent)),
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Price'),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Poppins',
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  '\$${(double.tryParse(data['service']?['Price']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)} x ${widget.bookings['quantity'].toString()} = ',
                                            ),
                                            TextSpan(
                                              text:
                                                  '\$${((double.tryParse(data['service']?['Price']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2) * (widget.bookings['quantity'] as int? ?? 0))}',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // This will space out the children across the row.
                                  children: [
                                    // Left-aligned text for the discount description and percentage
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        // Default style for the whole RichText
                                        children: [
                                          TextSpan(
                                            text:
                                                'Discount ', // Normal text in black
                                          ),
                                          TextSpan(
                                            text:
                                                ' (${data['coupon']['discount'] ?? '0'}% off',
                                            // Discount percentage in green
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ')',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold,
                                            ), // Closing parenthesis in black
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Right-aligned text for the calculated discount value
                                    Text(
                                      '-\$${(double.parse(data['service']['Price'] ?? '0') * double.parse(widget.bookings['quantity'].toString()) * (double.parse(data['coupon']['discount'] ?? '0') / 100)).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ), // This makes the price bold and green
                                    ),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tax',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                        )),
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.attach_money,
                                                            color:
                                                                Colors.green),
                                                        title:
                                                            Text('Booking Fee'),
                                                        subtitle: Text(
                                                            '\$${bookingFee.toStringAsFixed(2)}'),
                                                      ),
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.percent,
                                                            color: Colors.blue),
                                                        title:
                                                            Text('Service Tax'),
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
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                backgroundColor:
                                                                    Colors
                                                                        .redAccent),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon:
                                              Icon(Icons.info_outline_rounded),
                                        ),
                                        Text(
                                            ' \$${widget.bookings['tax']?.toStringAsFixed(2) ?? '0.00'}',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Amount',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Text(
                                        ' \$${widget.bookings['total']?.toStringAsFixed(2) ?? '0.00'}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                              ]),
                          // Text(

                          // SizedBox(height: 10),
                          // Text(
                          //     'Total Price: \$${widget.bookings['total']?.toStringAsFixed(2) ?? '0.00'}',
                          //     style: TextStyle(fontSize: 16)),
                          // SizedBox(height: 10),

                          // // Add more fields as necessary
                        ),
                      ),
                      SizedBox(height: 20),
                      if (bookingStatus == 'Accepted' ||
                          bookingStatus == 'Pending') ...[
                        Center(
                          child: Row(
                            // Use a Row to arrange the buttons horizontally
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Add some spacing between buttons
                              ElevatedButton(
                                onPressed: () {
                                  // Controller for the cancellation reason text field
                                  TextEditingController reasonController =
                                      TextEditingController();

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Cancel Booking'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                'Are you sure you want to cancel this booking? This action cannot be undone.'),
                                            SizedBox(height: 16),
                                            // Add some spacing
                                            TextField(
                                              controller: reasonController,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Reason for Cancellation (Optional)',
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();

                                              String cancellationReason =
                                                  reasonController.text.trim();
                                              updateBookingStatus1(
                                                  cancellationReason);
                                            },
                                            child: Text('Yes'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                ),
                                child: Text('Cancel'),
                              ),
                            ],
                          ),
                        )
                      ]
                    ]),
              ));
        },
      ),
    );
  }

  void _listenToProviderReadiness(String bookingId) {
    FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> bookingData =
            snapshot.data() as Map<String, dynamic>;

        if (bookingData['status'] == 'Ready to Service') {
          // Perform actions when the service provider is ready
          // For example, navigate the customer to the service start page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Service provider is ready to start the service')),
          );

          // Navigate to a new screen or perform any other necessary actions
          // Navigator.push(context, MaterialPageRoute(...));
        }
      }
    });
  }
}
