// adminfeedback.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/util/AppColors.dart';

class adminfeedback extends StatefulWidget {
  final List<DocumentSnapshot> reviews;
  final String title;
  const adminfeedback({super.key, required this.reviews,required this.title});

  @override
  State<adminfeedback> createState() => _adminfeedbackState();
}

class _adminfeedbackState extends State<adminfeedback> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String> _fetchCustomerFullName(String customerId) async {
    try {
      print('Fetching customer name for ID: $customerId');
      var doc = await _firestore.collection('customer').doc(customerId).get();
      if (doc.exists) {
        var data = doc.data();
        print('Customer data: $data');
        String firstName = data?['FirstName'] ?? 'Customer';
        String lastName = data?['LastName'] ?? '';
        return '$firstName $lastName'.trim();
      } else {
        print('Customer document not found.');
        return 'Customer';
      }
    } catch (error) {
      print('Error fetching customer name: $error');
      return 'Customer';
    }
  }

  Future<String> _fetchproviderFullName(String providerId) async {
    try {
      print('Fetching provider name for ID: $providerId');
      var doc = await _firestore.collection('provider').doc(providerId).get();
      if (doc.exists) {
        var data = doc.data();
        print('Provider data: $data');
        String firstName = data?['FirstName'] ?? 'Provider';
        String lastName = data?['LastName'] ?? '';
        return '$firstName $lastName'.trim();
      } else {
        print('Provider document not found.');
        return 'Provider';
      }
    } catch (error) {
      print('Error fetching provider name: $error');
      return 'Provider';
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          ' ${widget.title} ',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: widget.reviews.isEmpty
          ? Center(
        child: Text(
           'No ${widget.title} available.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      )
          : ListView.builder(
        itemCount: widget.reviews.length,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemBuilder: (context, index) {
          var reviewData = widget.reviews[index].data() as Map<String, dynamic>;
          return FutureBuilder<List<String>>(
            future: Future.wait([
              _fetchCustomerFullName(reviewData['customerId']),
              _fetchproviderFullName(reviewData['providerId']),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return ListTile(
                  title: const Text('Error loading customer/provider details'),
                  subtitle: const Text('Please try again later.'),
                );
              }

              final names = snapshot.data!;
              final customerName = names[0];
              final providerName = names[1];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [



                        // Customer and Provider Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Customer:',
                              style:  TextStyle(
                                fontFamily: 'Poppins',
                                // fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),),
                              Text(
                              customerName,
                              style:  TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              ),
                          ],
                        ),
                            Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Provider:',
                              style:  TextStyle(
                                fontFamily: 'Poppins',
                                // fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              providerName,
                              style:  TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Divider(color: Colors.grey[300]),

                        // Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.solidStar,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              ' ${reviewData['emojiRating']}.0/5',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Feedback
                        if (reviewData['feedback'] != null &&
                            reviewData['feedback'] is Map)
                          ...reviewData['feedback'].entries.map((entry) {
                            return Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    color: Colors.black87,
                                  ),
                                ),
                                Icon(
                                  entry.value == 1
                                      ? Icons.thumb_up_alt_rounded
                                      : (entry.value == -1
                                      ? Icons
                                      .thumb_down_alt_rounded
                                      : Icons.help_outline),
                                  color: entry.value == 1
                                      ? Colors.green
                                      : (entry.value == -1
                                      ? Colors.red
                                      : Colors.grey),
                                ),
                              ],
                            );
                          }).toList(),

                        const SizedBox(height: 12),

                        // Comments
                        if (reviewData['notes'] != null &&
                            reviewData['notes'].isNotEmpty)
                          Text(
                            'Comments: ${reviewData['notes']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          const Text(
                            'No comments provided.',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}