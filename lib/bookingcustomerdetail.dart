import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';

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

  void updateBookingStatus(String cancellationReason) async {
    try {
      String bookingId = widget.bookings.id;

      // 1. Update the booking status and include cancellation reason
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'Cancelled',
        'cancellationReason': cancellationReason, // Add the reason
      });

      // 2. Find the corresponding notification
      QuerySnapshot notificationSnapshot = await _firestore
          .collection('notifications')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot notificationDoc = notificationSnapshot.docs.first;

        // 3. Update the notification with the reason (if provided)
        String providerMessage = 'Your booking has been cancelled by the customer.';
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
        return Colors
            .green[900]!;
      case 'Payment Pending':
        return Colors
            .deepPurple[900]!; // A dark green to represent finality and success.

      case 'On going':
        return Colors.blue[800]!;
      case 'In Process':
        return Colors
            .brown[800]!; // A dark blue that conveys stability and continuity.

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
                      if ((bookingStatus == 'Accepted' || bookingStatus == 'In Process' ) && paymentstatus =='Pending' ) ...[
                        Column(

                          children: [

                            Text('Your booking request is accepted please select payment method for further processing ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(height: 5),

                          ],
                        ), SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),
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
                                  color:Colors.grey,
                                  fontFamily: 'Poppins',
                                )),
                          ],
                        ), SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),
                      ],
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


                    ]),
              ));
        },
      ),
    );
  }
}
