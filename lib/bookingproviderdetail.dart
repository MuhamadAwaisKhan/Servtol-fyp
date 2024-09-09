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

  @override
  void initState() {
    super.initState();
    fetchTaxRate();
    fetchBookingFee();
  }

  void updateBookingStatus(String newStatus, String notificationMessage,
      String notificationMessage1) async {
    try {
      String bookingId = widget.bookings.id;
      String providerId = widget.bookings['providerId'];
      String serviceNameLower =
      (widget.bookings['ServiceName'] ?? '').toString().toLowerCase();

      WriteBatch batch = _firestore.batch();

      // 1. Update the booking status
      DocumentReference bookingRef =
      _firestore.collection(bookingsCollection).doc(bookingId);
      batch.update(bookingRef, {'status': newStatus});

      // 2. Find the corresponding notification using bookingId
      QuerySnapshot notificationSnapshot = await _firestore
          .collection(notificationsCollection)
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot notificationDoc = notificationSnapshot.docs.first;

        // 3. Update the notification
        DocumentReference notificationRef = _firestore
            .collection(notificationsCollection)
            .doc(notificationDoc.id);
        batch.update(notificationRef, {
          'status': newStatus,
          'message': notificationMessage,
          'message1': notificationMessage1,
        });
      } else {
        print('No notification found for booking ID: $bookingId');
      }

      await batch.commit().catchError((error) {
        print('Error committing batch: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to update booking and notification. Please try again.')),
        );
        return;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking status updated to $newStatus')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
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
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange; // Or any color you prefer for pending
      case 'Cancelled':
        return Colors.grey;
      case 'Rejected':
        return Colors.red;
      case 'Accepted':
        return Colors.green;
      default:
        return Colors.redAccent; // Default color for unknown statuses
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal:
              8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(widget.bookings['status'] as String? ?? 'Pending'),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.bookings['status'] as String? ?? 'Pending',
            style: TextStyle(
              color: Colors.white,
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
          var bookingStatus = widget.bookings['status'] as String? ??
              ''; // Get the booking status

          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
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
                            border: Border.all(color: Colors.deepPurpleAccent)),
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
                                                          color: Colors.green),
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
                                        icon: Icon(Icons.info_outline_rounded),
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
                                    'Your booking has been rejected.');
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red, // Red for Reject
                              ),
                              child: Text('Reject'),
                            ),
                          ],
                        ),
                      )
                    ] // Conditionally display the "Reject" button
                  ]));
        },
      ),
    );
  }
}