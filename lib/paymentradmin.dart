import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/util/AppColors.dart';

class paymentadmin extends StatefulWidget {
  final String paymentMethod;
  final String title;

  paymentadmin({super.key,required this.paymentMethod,required this.title});

  @override
  State<paymentadmin> createState() => _paymentadminState();
}

class _paymentadminState extends State<paymentadmin> {

  // final User? currentUser = FirebaseAuth.instance.currentUser;
  Stream<QuerySnapshot> _paymentStream() {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('Method', isEqualTo: widget.paymentMethod) // Filter by paymentMethod
        .snapshots();
  }


  Future<Map<String, dynamic>?> fetchDocument(
      String collection, String documentId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .get();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
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
          Lottie.asset('assets/images/payments.json', height: 200),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _paymentStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue), // Blue loader
                      ));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                          Text(
                          'No payment records found.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,

                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  children:
                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: fetchPaymentDetails(
                          document.data() as Map<String, dynamic>),
                      builder: (context, detailsSnapshot) {
                        if (detailsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                              ));
                        }
                        if (detailsSnapshot.hasError ||
                            detailsSnapshot.data == null) {
                          return const Text(
                              'Error: Failed to fetch payment details');
                        }
                        return paymentCard(detailsSnapshot.data!);
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

  Future<Map<String, dynamic>> fetchPaymentDetails(
      Map<String, dynamic> paymentData) async {
    try {
      Map<String, dynamic> result = {};

      // Fetch booking details
      var bookingData = await fetchDocument('bookings', paymentData['bookingId']);

      // Fetch customer details
      var customerData =
      await fetchDocument('customer', bookingData!['customerId']);

      result['paymentId'] = paymentData['paymentId'];
      result['status'] = paymentData['paymentstatus'];
      result['method'] = paymentData['Method'];
      result['amount'] = bookingData['total']; // Amount from booking
      result['customerName'] =
      "${customerData!['FirstName']} ${customerData['LastName']}";
      result['bookingId'] = paymentData['bookingId']; // Include bookingId

      return result;
    } catch (e) {
      print("Error fetching payment details: $e");
      return {};
    }
  }

  Widget paymentCard(Map<String, dynamic> data) {
    return Card(
      color: Colors.lightBlueAccent, // Using your primary color
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          data['customerName'] ?? 'Unknown Customer',
          style: TextStyle(
              color: Colors.white, fontFamily: 'Poppins'), // Using your font and white color
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID:',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${data['bookingId'] ?? 'N/A'}', // Display bookingId
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment ID:',
                  style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                ),
                Text(
                  '${data['paymentId'] ?? 'N/A'}',
                  style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status:',
                  style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                ),
                Text(
                  '${data['status'] ?? 'N/A'}',
                  style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Method:',
                  style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                ),
                Text(
                  '${data['method'] ?? 'N/A'}',
                  style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '\$${(data['amount'] != null ? data['amount'].toStringAsFixed(2) : '0.00')}',
                    style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),          ],
        ),
      ),
    );
  }
}