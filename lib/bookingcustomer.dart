import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servtol/util/AppColors.dart';

class BookingCustomer extends StatefulWidget {
  const BookingCustomer({Key? key}) : super(key: key);

  @override
  _BookingCustomerState createState() => _BookingCustomerState();
}

class _BookingCustomerState extends State<BookingCustomer> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generalized method to fetch documents from Firestore
  Future<Map<String, dynamic>?> fetchDocument(String collection, String documentId) async {
    try {
      var snapshot = await _firestore.collection(collection).doc(documentId).get();
      if (snapshot.exists && snapshot.data() != null) {
        print("$collection Data: ${snapshot.data()}");
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

  Future<Map<String, dynamic>> fetchBookingDetails(Map<String, dynamic> bookingData) async {
    try {
      Map<String, dynamic> result = {};

      var providerData = await fetchDocument('provider', bookingData['providerId']);
      var couponData = await fetchDocument('coupons', bookingData['couponId']);
      var serviceData = await fetchDocument('service', bookingData['serviceId']);

      // Make sure to include booking-specific details
      result['provider'] = providerData ?? {};
      result['coupon'] = couponData ?? {};
      result['service'] = serviceData ?? {};
      result['bookingId'] = bookingData['bookingId'];
      result['status'] = bookingData['status'];
      result['date'] = bookingData['date'];
      result['time'] = bookingData['time'];
      result['total'] = bookingData['total']; // Example for total amount
      result['address'] = bookingData['address'];
      result['discount'] = bookingData['discount']; // Example for discount

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
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('bookings').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchBookingDetails(data),
                  builder: (context, detailSnapshot) {
                    if (detailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (detailSnapshot.hasError ||
                        detailSnapshot.data == null) {
                      return Text('Error: Failed to fetch booking details');
                    }
                    return bookingCard(detailSnapshot.data!);
                  },
                );
              }).toList(),
            );
          },
        ));
  }

  Widget bookingCard(Map<String, dynamic> data) {
    print("Data being passed to bookingCard: $data");

    // Extracting nested data safely
    String serviceType = (data['service']?['ServiceType'] as String? ?? '').toLowerCase();
    bool isRemoteService = serviceType == 'remote';
    String serviceName = data['service']?['ServiceName'] as String? ?? 'No Service';
    String servicePrice = data['service']?['Price'].toString() ?? '0.00';
    String discount = data['coupon']?['discount'].toString() ?? '0';

    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (data['status'] as String? ?? '').toLowerCase() == 'rejected'
                        ? Colors.red
                        : Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    data['status'] as String? ?? 'Pending',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Text(
                  '#${data['bookingId'] as String? ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              serviceName,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "\$$servicePrice ($discount% Off)",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Date', style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(
                  data['date'] as String? ?? 'No Date',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text('At', style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(
                  data['time'] as String? ?? 'No time',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Provider', style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text(
              "${data['provider']?['FirstName'] as String? ?? 'No First Name'} ${data['provider']?['LastName'] as String? ?? ''}",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('Payment Status', style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text(
              data['paymentStatus'] as String? ?? 'Pending',
              style: TextStyle(color: Colors.amber[800], fontSize: 16),
            ),
            if (!isRemoteService) ...[
              SizedBox(height: 10),
              Text('Your Address', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(
                data['address'] as String? ?? 'No Address',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
