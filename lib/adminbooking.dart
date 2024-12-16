import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/bookingcustomerdetail.dart';
import 'package:servtol/util/AppColors.dart';
class adminbooking extends StatefulWidget {
  final String bookingStatus;

  adminbooking({super.key,required this.bookingStatus });

  @override
  State<adminbooking> createState() => _adminbookingState();
}

class _adminbookingState extends State<adminbooking> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final User? currentUser = FirebaseAuth.instance.currentUser;
  String? customerId;

  // = currentUser?.uid;
  @override
  void initState() {
    super.initState();
    // customerId = currentUser?.uid; // Initialize customerId in initState
  }

  Future<void> _updateDateTime(BuildContext context, String bookingId) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        // Confirm the update via an AlertDialog
        showDialog(
          context: context,
          builder: (ctx) =>
              AlertDialog(
                title: Text("Confirm Update"),
                content: Text(
                    "Do you want to update the booking to:\nDate: ${pickedDate
                        .toString().substring(0, 10)}\nTime: ${pickedTime
                        .format(context)}?"),
                actions: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // Close the dialog
                    },
                  ),
                  TextButton(
                    child: Text("Update"),
                    onPressed: () async {
                      // Perform the update on Firestore
                      await _firestore
                          .collection('bookings')
                          .doc(bookingId)
                          .update({
                        'date': pickedDate.toString().substring(0, 10),
                        // Store date as a string
                        'time': pickedTime.format(context),
                        // Store time as a string
                      });
                      Navigator.of(ctx).pop(); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Booking updated successfully!')),
                      );
                    },
                  ),
                ],
              ),
        );
      }
    }
  }

  // Generalized method to fetch documents from Firestore
  Future<Map<String, dynamic>?> fetchDocument(String collection,
      String documentId) async {
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

  Future<Map<String, dynamic>> fetchBookingDetails(
      Map<String, dynamic> bookingData) async {
    try {
      Map<String, dynamic> result = {};

      var providerData =
      await fetchDocument('provider', bookingData['providerId']);
      var customerData =
      await fetchDocument('customer', bookingData['customerId']);
      var couponData = await fetchDocument('coupons', bookingData['couponId']);
      var serviceData =
      await fetchDocument('service', bookingData['serviceId']);

      // Make sure to include booking-specific details
      result['provider'] = providerData ?? {};
      result['customer'] = customerData ?? {};
      result['coupon'] = couponData ?? {};
      result['service'] = serviceData ?? {};
      result['bookingId'] = bookingData['bookingId'];
      result['status'] = bookingData['status'];
      result['paymentstatus'] = bookingData['paymentstatus'];
      result['date'] = bookingData['date'];
      result['time'] = bookingData['time'];
      result['total'] = bookingData['total']; // Example for total amount
      result['address'] = bookingData['address'];
      result['discount'] = bookingData['discount'];
      result['quantity'] = bookingData['quantity'];

      return result;
    } catch (e) {
      print("Error fetching booking details: $e");
      return {};
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
  Stream<QuerySnapshot> _getBookingStream() {
    if (widget.bookingStatus == 'All') {
      return _firestore.collection('bookings').snapshots();
    } else if (widget.bookingStatus == 'Pending') {
      return _firestore.collection('bookings')
          .where('status', isEqualTo: 'Pending')
          .snapshots();
    }
    else if (widget.bookingStatus == 'Complete') {
      return _firestore.collection('bookings')
          .where('status', isEqualTo: 'Complete')
          .snapshots();
    }

    else  {
      // Add more conditions for other statuses if needed
      return _firestore.collection('bookings').snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Bookings",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/images/bookingc.json', height: 200),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
              stream: _getBookingStream(), // Use a function to get the stream
      builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children:
                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: fetchBookingDetails(
                          document.data() as Map<String, dynamic>),
                      builder: (context, detailSnapshot) {
                        if (detailSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (detailSnapshot.hasError ||
                            detailSnapshot.data == null) {
                          return Text('Error: Failed to fetch booking details');
                        }
                        return bookingCard(detailSnapshot.data!, document);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget bookingCard(Map<String, dynamic> data, DocumentSnapshot document) {
    // Ensure service and nested fields are accessed safely
    String serviceType =
    (data['service']?['ServiceType'] as String? ?? '').toLowerCase();
    bool isRemoteService = serviceType == 'remote';

    String serviceName = data['service']?['ServiceName'] as String? ?? 'No Service';
    String servicePrice = data['service']?['Price']?.toString() ?? '0.00';
    String discount = data['coupon']?['discount']?.toString() ?? '0';

    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookingCustomerDetail(bookings: document),
        //   ),
        // );
      },
      child: Card(
        margin: EdgeInsets.all(8),
        color: Colors.indigoAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data['status'] as String? ?? 'Pending'),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      data['status'] as String? ?? 'Pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${data['bookingId'] as String? ?? 'Unknown'}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipOval(
                    child: SizedBox(
                      height: 70,
                      width: 70,
                      child: Image.network(
                        data['service']?['ImageUrl'] ??
                            'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=',
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),

                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Text('Failed to load image'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          serviceName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "\$$servicePrice ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "($discount% Off)",
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Date',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                    data['date'] as String? ?? 'No Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('At',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                    data['time'] as String? ?? 'No time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.heading12,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurpleAccent)),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Provider',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                              "${data['provider']?['FirstName'] as String? ??
                                  'No First Name'} ${data['provider']?['LastName'] as String? ??
                                  ''}",
                              style: TextStyle(
                                color: Colors.cyan,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Customer',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                              "${data['customer']?['FirstName'] as String? ??
                                  'No First Name'} ${data['customer']?['LastName'] as String? ??
                                  ''}",
                              style: TextStyle(
                                color: Colors.cyan,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payment Status',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                              data['paymentstatus'] as String? ?? 'Pending',
                              style: TextStyle(
                                color: _getPaymentStatusColor(data['paymentstatus'] as String? ?? 'No payments'),

                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (!isRemoteService) ...[
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Address',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Flexible( // Added Flexible widget
                                child: Text(
                                  data['address'] as String? ?? 'No Address',
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}

