import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/bookingproviderdetail.dart'; // Ensure this is correct
import 'package:servtol/util/AppColors.dart';

class BookingScreenWidget extends StatefulWidget {
  final Function onBackPress;

  BookingScreenWidget({Key? key, required this.onBackPress}) : super(key: key);

  @override
  State<BookingScreenWidget> createState() => _BookingScreenWidgetState();
}

class _BookingScreenWidgetState extends State<BookingScreenWidget> {
  TextEditingController searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Object?>> _bookingStream(String searchText) {
    String? providerId = currentUser?.uid;

    if (providerId == null) {
      return Stream.empty(); // Return an empty stream if providerId is null
    }

    if (searchText.isEmpty) {
      return _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .snapshots();
    } else {
      bool isNumeric = double.tryParse(searchText) != null;
      if (isNumeric) {
        // Searching by Booking ID
        return _firestore
            .collection('bookings')
            .where('providerId', isEqualTo: providerId)
            .where('bookingId', isEqualTo: searchText)
            .snapshots();
      } else {
        // Searching by Service Name (case-insensitive)
        searchText =
            searchText.toLowerCase(); // Ensure search term is in lowercase
        return _firestore
            .collection('bookings')
            .where('providerId', isEqualTo: providerId)
            .where('serviceNameLower', isGreaterThanOrEqualTo: searchText)
            .where('serviceNameLower',
                isLessThanOrEqualTo: searchText + '\uf8ff')
            .snapshots();
      }
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

      result['provider'] = providerData ?? {};
      result['coupon'] = couponData ?? {};
      result['service'] = serviceData ?? {};
      result['customer'] = customerData ?? {};
      result['bookingId'] = bookingData['bookingId'];
      result['status'] = bookingData['status'];
      result['date'] = bookingData['date'];
      result['time'] = bookingData['time'];
      result['total'] = bookingData['total'];
      result['address'] = bookingData['address'];
      result['discount'] = bookingData['discount'];
      result['quantity'] = bookingData['quantity'];
      result['paymentstatus'] = bookingData['paymentstatus'];

      return result;
    } catch (e) {
      print("Error fetching booking details: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
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
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(10),
          //   child: TextField(
          //     controller: searchController,
          //     style: const TextStyle(fontSize: 16),
          //     decoration: InputDecoration(
          //       labelText: 'Search Bookings',
          //       labelStyle: const TextStyle(fontFamily: 'Poppins'),
          //       prefixIcon: const Icon(Icons.search, color: Colors.grey),
          //       suffixIcon: searchController.text.isNotEmpty
          //           ? GestureDetector(
          //         child: const Icon(Icons.clear, color: Colors.grey),
          //         onTap: () {
          //           searchController.clear();
          //           setState(() {});
          //         },
          //       )
          //           : null,
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(25),
          //         borderSide: BorderSide.none,
          //       ),
          //       filled: true,
          //       fillColor: Colors.white,
          //       contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          //     ),
          //     onChanged: (value) {
          //       setState(() {});
          //     },
          //   ),
          // ),
          Lottie.asset('assets/images/booking.json', height: 200),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _bookingStream(searchController.text.trim()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No bookings found.'));
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
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (detailSnapshot.hasError ||
                            detailSnapshot.data == null) {
                          return const Text(
                              'Error: Failed to fetch booking details');
                        }
                        return bookingCard(
                            detailSnapshot.data!, document, context);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

Widget bookingCard(Map<String, dynamic> data, DocumentSnapshot document,
    BuildContext context) {
  String serviceType =
      (data['service']?['ServiceType'] as String? ?? '').toLowerCase();
  bool isRemoteService = serviceType == 'remote';
  String serviceName =
      data['service']?['ServiceName'] as String? ?? 'No Service';
  String servicePrice = data['service']?['Price'].toString() ?? '0.00';
  String discount = data['coupon']?['discount'].toString() ?? '0';

  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => bookingproviderdetail(
            bookings: document,
          ),
        ),
      );
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(data['status'] as String? ?? 'Pending'),
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
                  '#${data['bookingId'] as String? ?? 'Unknown'}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // (data['status'] as String? ?? '').toLowerCase() == 'pending' ? IconButton(
                //   onPressed: () {
                //     _updateDateTime(context, data['bookingId']);
                //   },
                //   icon: Icon(FontAwesomeIcons.penToSquare, size: 16, color: Colors.white),
                // ) : Container(),  // Show nothing if not pending
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipOval(
                  child: SizedBox(
                    height: 70, // Specifies the height of the image
                    width: 70, // Specifies the width of the image
                    child: Image.network(
                      data['service']['ImageUrl'] ??
                          'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=',
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
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
                Padding(
                  padding: const EdgeInsets.only(right: 115.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        serviceName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "\$$servicePrice ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "($discount% Off)",
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 16,
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
                      if (!isRemoteService) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Your Address',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                              data['address'] as String? ?? 'No Address',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date & Time',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                data['date'] as String? ?? 'Pending',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'At',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                data['time'] as String? ?? 'Pending',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              )),
                          Text(
                            "${data['customer']?['FirstName'] as String? ?? 'No First Name'} ${data['customer']?['LastName'] as String? ?? ''}",
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            )
          ],
        ),
      ),
    ),
  );
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