import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servtol/reviewprovider.dart';

import 'package:servtol/util/AppColors.dart';
// Assuming AppColors is defined elsewhere

class CustomerReviewByProvider extends StatefulWidget {
  final String providerId;
  CustomerReviewByProvider({super.key, required this.providerId});

  @override
  State<CustomerReviewByProvider> createState() => _CustomerReviewByProviderState();
}

class _CustomerReviewByProviderState extends State<CustomerReviewByProvider> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<List<DocumentSnapshot>> _fetchProviderServices() async {
    try {
      // Use widget.providerId to fetch services for the specified provider
      var servicesSnapshot = await _firestore
          .collection('service')
          .where('providerId', isEqualTo: widget.providerId)
          .get();
      return servicesSnapshot.docs;
    } catch (error) {
      print('Error fetching services: $error');
      return [];
    }
  }

  Future<String> _fetchCustomerFullName(String customerId) async {
    try {
      var doc = await _firestore.collection('customer').doc(customerId).get();
      if (doc.exists) {
        var data = doc.data();
        String firstName = data?['FirstName'] ?? 'Customer';
        String lastName = data?['LastName'] ?? '';
        return '$firstName $lastName'.trim();
      } else {
        return 'Customer';
      }
    } catch (error) {
      print('Error fetching customer name: $error');
      return 'Customer';
    }
  }

  Future<List<DocumentSnapshot>> _fetchReviews(String serviceId) async {
    try {
      var reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId) // Filter reviews by serviceId
          .get();
      return reviewsSnapshot.docs;
    } catch (error) {
      print('Error fetching reviews: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          "Reviews Section",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(child: _buildServicesList()),
    );
  }

  Widget _buildServicesList() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchProviderServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),

          ));
        }
        var services = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Services Provided',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              if (services.isNotEmpty)
                ...services.map((serviceSnapshot) {
                  var service = serviceSnapshot.data() as Map<String, dynamic>;
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          service['ImageUrl'] ??
                              'https://yourfallbackimageurl.com',
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        service['ServiceName'] ?? 'Service',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Price: \u20A8 ${service['Price']}',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Colors.blueAccent),
                      onTap: () async {
                        setState(() {
                          _isLoading = true; // Show loading indicator
                        });
                        // Fetch reviews for this service
                        var reviews = await _fetchReviews(serviceSnapshot.id);
                        setState(() {
                          _isLoading = false;
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceReviewsScreen(
                              service: service,
                              reviews: reviews,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList()
              else
                Text('No services available.'),
            ],
          ),
        );
      },
    );
  }
}

