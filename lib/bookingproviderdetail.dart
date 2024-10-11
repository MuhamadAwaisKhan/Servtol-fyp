import 'dart:async';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';

class bookingproviderdetail extends StatefulWidget {
  final DocumentSnapshot bookings;

  const bookingproviderdetail({super.key, required this.bookings});

  @override
  State<bookingproviderdetail> createState() => _bookingproviderdetailState();
}

class _bookingproviderdetailState extends State<bookingproviderdetail> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String bookingsCollection = 'bookings';
  static const String notificationsCollection = 'notifications';

  // Declare these variables in the state class
  double taxRate = 0.05; // Default value
  double bookingFee = 0.0; // Default value
  final _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose(); // Dispose of the StopWatchTimer
  }

  @override
  void initState() {
    super.initState();
    fetchTaxRate();
    fetchBookingFee();
    // _timer?.cancel();
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
      'customer': {},
    };

    if (bookingData['providerId'] != null) {
      result['provider'] =
          await fetchDocument('provider', bookingData['providerId']);
    }
    if (bookingData['customerId'] != null) {
      result['customer'] =
          await fetchDocument('customer', bookingData['customerId']);
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
        return Colors
            .brown[800]!; // A dark blue that conveys stability and continuity.
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

  void _showBookingStatusStepper(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Status'),
          content: FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('bookings').doc(widget.bookings.id).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(child: Text('Error fetching booking status'));
              }

              var bookingData = snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> statusHistory = bookingData['statusHistory'] ?? [];

              List<Step> steps = [];
              for (var i = 0; i < statusHistory.length; i++) {
                var statusData = statusHistory[i];
                String status = statusData['status'];
                Timestamp timestamp = statusData['timestamp'];
                DateTime dateTime = timestamp.toDate();

                steps.add(
                  Step(
                    title: Text(status),
                    content: Text(
                        '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}'),
                    isActive: i == statusHistory.length - 1, // Last step is active
                  ),
                );
              }

              return Container(
                height: 300, // Adjust height as needed
                width: 300, // Adjust width as needed
                child: Stepper(
                  currentStep: steps.length - 1, // Always show the last step
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling
                  controlsBuilder: (context, details) => SizedBox.shrink(), // Hide the controls
                  steps: steps,
                ),
              );
            },
          ),
        );
      },
    );
  }
  void updateBookingStatus(String newStatus, String notificationMessage,
      String notificationMessage1) async {
    try {
      String bookingId = widget.bookings.id;
      WriteBatch batch = _firestore.batch();

      // Fetch the booking document to get the current statusHistory
      DocumentSnapshot bookingSnapshot = await _firestore.collection('bookings').doc(bookingId).get();
      List<dynamic> statusHistory = bookingSnapshot.get('statusHistory') ?? [];

      // Add the new status to the history
      statusHistory.add({
        'status': newStatus,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update notification if it exists
      QuerySnapshot notificationSnapshot = await _firestore
          .collection(notificationsCollection)
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot notificationDoc = notificationSnapshot.docs.first;
        DocumentReference notificationRef = _firestore
            .collection(notificationsCollection)
            .doc(notificationDoc.id);
        batch.update(notificationRef, {
          'status': newStatus,
          'message': notificationMessage,
          'message1': notificationMessage1,
        });

        DocumentReference bookingRef =
        _firestore.collection(bookingsCollection).doc(bookingId);
        batch.update(bookingRef, {
          'status': newStatus,
          'statusHistory': statusHistory, // Update the status history in Firestore
        });
      }

      // Commit changes
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking status updated to $newStatus')),
      );
      setState(() {});
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  void updateBookingStatus1(String cancellationReason) async {
    try {
      String bookingId = widget.bookings.id;

      // Fetch the booking document to get the current statusHistory
      DocumentSnapshot bookingSnapshot = await _firestore.collection('bookings').doc(bookingId).get();
      List<dynamic> statusHistory = bookingSnapshot.get('statusHistory') ?? [];

      // Add the new status to the history
      statusHistory.add({
        'status': 'Cancelled',
        'timestamp': FieldValue.serverTimestamp(),
      });

      WriteBatch batch = _firestore.batch();

      // Update the booking status and include cancellation reason
      DocumentReference bookingRef = _firestore.collection('bookings').doc(bookingId);
      batch.update(bookingRef, {
        'status': 'Cancelled',
        'cancellationReason': cancellationReason,
        'statusHistory': statusHistory, // Update the status history in Firestore
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Find the corresponding notification
      QuerySnapshot notificationSnapshot = await _firestore
          .collection('notifications')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot notificationDoc = notificationSnapshot.docs.first;
        DocumentReference notificationRef = _firestore
            .collection('notifications')
            .doc(notificationDoc.id);

        // Update the notification with the reason (if provided)
        String providerMessage = 'You have cancelled the service booking.';
        String customerMessage =
            'Your booking has been cancelled by the service provider.';

        batch.update(notificationRef, {
          'message': providerMessage,
          'message1': customerMessage,
          'status': 'Cancelled',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print('No notification found for booking ID: $bookingId');
      }

      // Commit changes
      await batch.commit();

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

  void updateBookingStatus2() async {
    try {
      String bookingId = widget.bookings.id;

      // Fetch the booking document to get the current statusHistory
      DocumentSnapshot bookingSnapshot = await _firestore.collection('bookings').doc(bookingId).get();
      List<dynamic> statusHistory = bookingSnapshot.get('statusHistory') ?? [];

      // Add the new status to the history
      statusHistory.add({
        'status': 'Complete',
        'timestamp': FieldValue.serverTimestamp(),
      });

      WriteBatch batch = _firestore.batch();

      // Update the booking status
      DocumentReference bookingRef = _firestore.collection('bookings').doc(bookingId);
      batch.update(bookingRef, {
        'status': 'Complete',
        'statusHistory': statusHistory, // Update the status history in Firestore
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Find the corresponding notification
      QuerySnapshot notificationSnapshot = await _firestore
          .collection('notifications')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot notificationDoc = notificationSnapshot.docs.first;
        DocumentReference notificationRef = _firestore
            .collection('notifications')
            .doc(notificationDoc.id);

        // Update the notification
        String providerMessage = 'You have complete the service booking.';
        String customerMessage =
            'Your booking has been complete by the service provider.';

        batch.update(notificationRef, {
          'message': providerMessage,
          'message1': customerMessage,
          'status': 'Complete',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print('No notification found for booking ID: $bookingId');
      }

      // Commit changes
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking has been Complete')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to Complete booking')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(
                widget.bookings['status'] as String? ?? 'Pending'),
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
            onPressed: () {
              _showBookingStatusStepper(context);
            },
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
          var paymentstatus = widget.bookings['paymentstatus'] as String? ??
              ''; // Get the booking status

          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text('About Customer',
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
                              data['customer']['ProfilePic'] ??
                                  'https://via.placeholder.com/150', // Ensure this URL points to a valid placeholder
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                '${data['customer']['FirstName'] ?? 'Unknown'} ${data['provider']['LastName'] ?? ''}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow
                                    .ellipsis, // Prevents text from overflowing
                              ),
                              // IconButton(
                              //   onPressed: () {
                              //     // Define what happens when the info button is pressed
                              //   },
                              //   icon: Icon(Icons.info),
                              //   tooltip:
                              //       'More Info', // Tooltip text on long press
                              // )
                            ],
                          ),
                          // subtitle: Text(
                          //   "${data['provider']['Bio'] ?? 'No additional information'}",
                          //   style: TextStyle(color: Colors.grey[700]),
                          // ),
                          // onTap: () {
                          //   // Define what happens when you tap this ListTile
                          // },
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
                      if (bookingStatus == 'Pending') ...[
                        Center(
                          child: Row(
                            // Use a Row to arrange the buttons horizontally
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  updateBookingStatus(
                                      'Accepted',
                                      'You have accepted the booking.',
                                      'Your booking is approved and wait for the next step.');
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.green, // Green for Accept
                                ),
                                child: Text('Accept'),
                              ),
                              SizedBox(width: 16),
                              // Add some spacing between buttons
                              ElevatedButton(
                                onPressed: () {
                                  updateBookingStatus(
                                      'Rejected',
                                      'You have rejected the booking.',
                                      'Your booking has been rejected and try again later.');
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red, // Red for Reject
                                ),
                                child: Text('Reject'),
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  updateBookingStatus(
                                      'Waiting',
                                      'You have processed the booking to waiting stage.',
                                      'Your booking is successfully processed and set waiting for the some time.');
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.blue, // Green for Accept
                                ),
                                child: Text('Waiting'),
                              ),
                            ],
                          ),
                        )
                      ],
                      if ((bookingStatus == 'Accepted' ||
                              bookingStatus == 'In Process') &&
                          paymentstatus == "Pending") ...[
                        Center(
                          child: Column(
                            children: [
                              Row(
                                // Use a Row to arrange the buttons horizontally
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      updateBookingStatus(
                                          'Waiting',
                                          'You have processed the booking to waiting stage.',
                                          'Your booking is successfully processed and set waiting for the some time.');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Colors.blue, // Green for Accept
                                    ),
                                    child: Text('Waiting'),
                                  ),
                                  SizedBox(width: 10),
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
                                                      reasonController.text
                                                          .trim();
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
                              SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () {
                                  updateBookingStatus(
                                      'Payment Pending',
                                      'You have updated the booking to "Payment Pending" status. Please wait for the customer to complete the payment to proceed further.',
                                      'Your booking is currently in "Payment Pending" status. Please complete the payment to continue with the service. Thank you for your cooperation!');
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.green, // Red for Reject
                                ),
                                child: Text('Ask Customer to Pay'),
                              ),
                            ],
                          ),
                        )
                      ],
                      if ((bookingStatus == 'Payment Pending') &&
                          paymentstatus == "Pending") ...[
                        Center(
                          child: Column(
                            children: [
                              Row(
                                // Use a Row to arrange the buttons horizontally
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      updateBookingStatus(
                                          'Waiting',
                                          'You have processed the booking to waiting stage.',
                                          'Your booking is successfully processed and set waiting for the some time.');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Colors.blue, // Green for Accept
                                    ),
                                    child: Text('Waiting'),
                                  ),
                                  SizedBox(width: 10),
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
                                                      reasonController.text
                                                          .trim();
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
                            ],
                          ),
                        )
                      ],
                      if ((bookingStatus == 'Ready to Service') &&
                          (paymentstatus == "OnCash" ||
                              paymentstatus == "Paid by Card")) ...[
                        Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Start the timer and update the status to 'In Progress'
                                      _stopWatchTimer.onStartTimer();
                                      // Correct method to start the timer
                                      updateBookingStatus(
                                        'In Progress',
                                        'You have just started working on the booking.',
                                        'Your booking for service is now in progress.',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors
                                          .blue, // Color for "Start" button
                                    ),
                                    child: Text('Start'),
                                  ),
                                ],
                              ),

                              // // Display the elapsed time if the stopwatch is running
                              // if (_isStopwatchRunning)
                              //   Text(
                              //     'Elapsed Time: $_elapsedTime',
                              //     style: TextStyle(fontSize: 16),
                              //   ),
                              // Display the StopWatchTimer only when 'Ready to Service'
                            ],
                          ),
                        ),
                      ],

                      if ((bookingStatus == 'In Progress') &&
                          (paymentstatus == "OnCash" ||
                              paymentstatus == "Paid by Card")) ...[
                        Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Show confirmation dialog to complete the booking
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Complete Booking'),
                                            content: Text(
                                                'Are you sure you want to complete this booking and stop the timer?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog

                                                  // Stop the StopWatchTimer
                                                  // _stopWatchTimer
                                                  //     .onStopTimer(); // Correct method to stop the timer
                                                  // int elapsedMilliseconds =
                                                  //     _stopWatchTimer
                                                  //         .rawTime.value;
                                                  // // Duration elapsedDuration =
                                                  //     Duration(
                                                  //         milliseconds:
                                                  //             elapsedMilliseconds);
                                                  // // String formattedElapsedTime =
                                                  //     _formatTime(
                                                  //         elapsedDuration);

                                                  // // Update the booking with the elapsed time from StopWatchTimer
                                                  // try {
                                                  //   String bookingId =
                                                  //       widget.bookings.id;
                                                  //   await _firestore
                                                  //       .collection('bookings')
                                                  //       .doc(bookingId)
                                                  //       .update({
                                                  //     'elapsedTime':
                                                  //         formattedElapsedTime,
                                                  //   });

                                                  // ScaffoldMessenger.of(
                                                  //         context)
                                                  //     .showSnackBar(
                                                  //   SnackBar(
                                                  //       content: Text(
                                                  //           'Elapsed time recorded: $formattedElapsedTime')),
                                                  // );
                                                  // } catch (e) {
                                                  //   print(
                                                  //       'Error updating booking with elapsed time: $e');
                                                  //   ScaffoldMessenger.of(
                                                  //           context)
                                                  //       .showSnackBar(
                                                  //     SnackBar(
                                                  //         content: Text(
                                                  //             'Failed to record elapsed time')),
                                                  //   );
                                                  // }

                                                  updateBookingStatus2(); // End the booking process
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
                                      backgroundColor: Colors
                                          .greenAccent, // Color for "End" button
                                    ),
                                    child: Text('End'),
                                  ),
                                ],
                              ),

                              // Display the elapsed time while the stopwatch is running
                              // Text(
                              //   'Elapsed Time: $_elapsedTime',
                              //   style: TextStyle(fontSize: 16),
                              // ),
                            ],
                          ),
                        ),
                      ],

                      // if (bookingStatus == 'Accepted') ...[
                      //   Center(
                      //     child: Row(
                      //       // Use a Row to arrange the buttons horizontally
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         ElevatedButton(
                      //           onPressed: () {
                      //             updateBookingStatus(
                      //                 'Waiting',
                      //                 'You have processed the booking to waiting stage.',
                      //                 'Your booking is successfully processed and set waiting for the some time.');
                      //           },
                      //           style: ElevatedButton.styleFrom(
                      //             foregroundColor: Colors.white,
                      //             backgroundColor:
                      //                 Colors.blue, // Green for Accept
                      //           ),
                      //           child: Text('Waiting'),
                      //         ),
                      //         SizedBox(width: 16),
                      //         // Add some spacing between buttons
                      //         ElevatedButton(
                      //           onPressed: () {
                      //             updateBookingStatus(
                      //                 'In Progress',
                      //                 'You have updated the booking to the In-Progress stage.',
                      //                 'Your booking has been successfully moved to "In Progress." The service provider is now working on your request. Thank you for your patience!');
                      //           },
                      //           style: ElevatedButton.styleFrom(
                      //             foregroundColor: Colors.white,
                      //             backgroundColor:
                      //                 Colors.green, // Red for Reject
                      //           ),
                      //           child: Text('Start'),
                      //         ),
                      //       ],
                      //     ),
                      //   )
                      // ],

                      if (bookingStatus == 'Waiting') ...[
                        Center(
                          child: Row(
                            // Use a Row to arrange the buttons horizontally
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  updateBookingStatus(
                                    'In Process',
                                    'You have updated the booking to the In-Process stage.',
                                    ' Your booking has been successfully moved to In Process. The service provider is currently handling your request. Thank you for your continued patience!',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.green, // Red for Reject
                                ),
                                child: Text('In Process'),
                              ),
                              SizedBox(width: 16),
                              // Add some spacing between buttons
                              Center(
                                child: ElevatedButton(
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
                                                    reasonController.text
                                                        .trim();
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
                              ),
                            ],
                          ),
                        )
                      ],
                      // if (bookingStatus == 'In Process') ...[
                      //   Center(
                      //     child: Row(
                      //       // Use a Row to arrange the buttons horizontally
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         ElevatedButton(
                      //           onPressed: () {
                      //             updateBookingStatus(
                      //               'In Process',
                      //               'You have updated the booking to the In-Process stage.',
                      //               ' Your booking has been successfully moved to In Process. The service provider is currently handling your request. Thank you for your continued patience!',
                      //             );
                      //           },
                      //           style: ElevatedButton.styleFrom(
                      //             foregroundColor: Colors.white,
                      //             backgroundColor:
                      //                 Colors.green, // Red for Reject
                      //           ),
                      //           child: Text('In Process'),
                      //         ),
                      //         SizedBox(width: 16),
                      //         // Add some spacing between buttons
                      //         Center(
                      //           child: ElevatedButton(
                      //             onPressed: () {
                      //               // Controller for the cancellation reason text field
                      //               TextEditingController reasonController =
                      //                   TextEditingController();
                      //
                      //               showDialog(
                      //                 context: context,
                      //                 builder: (BuildContext context) {
                      //                   return AlertDialog(
                      //                     title: Text('Cancel Booking'),
                      //                     content: Column(
                      //                       mainAxisSize: MainAxisSize.min,
                      //                       children: [
                      //                         Text(
                      //                             'Are you sure you want to cancel this booking? This action cannot be undone.'),
                      //                         SizedBox(height: 16),
                      //                         // Add some spacing
                      //                         TextField(
                      //                           controller: reasonController,
                      //                           decoration: InputDecoration(
                      //                             labelText:
                      //                                 'Reason for Cancellation (Optional)',
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                     actions: <Widget>[
                      //                       TextButton(
                      //                         onPressed: () {
                      //                           Navigator.of(context).pop();
                      //                         },
                      //                         child: Text('No'),
                      //                       ),
                      //                       TextButton(
                      //                         onPressed: () {
                      //                           Navigator.of(context).pop();
                      //
                      //                           String cancellationReason =
                      //                               reasonController.text
                      //                                   .trim();
                      //                           updateBookingStatus1(
                      //                               cancellationReason);
                      //                         },
                      //                         child: Text('Yes'),
                      //                       ),
                      //                     ],
                      //                   );
                      //                 },
                      //               );
                      //             },
                      //             style: ElevatedButton.styleFrom(
                      //               foregroundColor: Colors.white,
                      //               backgroundColor: Colors.red,
                      //             ),
                      //             child: Text('Cancel'),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   )
                      // ], // Conditionally display the "Reject" button
                    ]),
              ));
        },
      ),
    );
  }
}
