import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/util/AppColors.dart';

class ServiceReviewsScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final List<DocumentSnapshot> reviews;

  const ServiceReviewsScreen(
      {super.key, required this.service, required this.reviews});

  @override
  State<ServiceReviewsScreen> createState() => _ServiceReviewsScreenState();
}

class _ServiceReviewsScreenState extends State<ServiceReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service['ServiceName'] ?? 'Service Reviews',
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
          'No reviews available for this service.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      )
          : ListView.builder(
        itemCount: widget.reviews.length,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemBuilder: (context, index) {
          var reviewData =
          widget.reviews[index].data() as Map<String, dynamic>;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('customer')
                .doc(reviewData['customerId'])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return ListTile(
                  title: Text('Error loading customer details'),
                  subtitle: Text('Please try again later.'),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return ListTile(
                  title: Text('Customer not found.'),
                );
              }

              var customerData =
              snapshot.data!.data() as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.only(bottom: 16),
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
                      offset: Offset(0, 4),
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
                        // Customer Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                customerData['ProfilePic'] ?? '',
                              ),
                              onBackgroundImageError: (_, __) =>
                                  AssetImage('assets/default_avatar.png'),
                            ),
                            SizedBox(width: 16),
                            Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Customer Details Column
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        '${customerData['FirstName'] ??
                                            'Customer'} ${customerData['LastName'] ??
                                            ''}'.trim(),
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      if (customerData['Email'] != null)
                                        Text(
                                          customerData['Email'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Booking ID: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            reviewData['bookingId'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ]),
                            SizedBox(width: 55,),
                            // Rating Widget
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.solidStar,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  ' ${reviewData['emojiRating']}.0/5',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),


                        SizedBox(height: 16),
                        Divider(color: Colors.grey[300]),

                        // Rating

                        SizedBox(height: 12),

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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',

                                    color: Colors.black87,
                                  ),
                                ),
                                Icon(
                                  entry.value == 1
                                      ? Icons.thumb_up_alt_rounded
                                      : (entry.value == -1
                                      ? Icons.thumb_down_alt_rounded
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

                        SizedBox(height: 12),

                        // Comments
                        if (reviewData['notes'] != null &&
                            reviewData['notes'].isNotEmpty)
                          Row(
                            children: [
                              Text(
                                'Comments:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(
                                reviewData['notes'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: Colors.black87,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
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
