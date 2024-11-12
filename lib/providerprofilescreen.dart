import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/util/AppColors.dart';

class ProviderProfileView extends StatefulWidget {
  final String providerId;

  ProviderProfileView({super.key, required this.providerId});

  @override
  State<ProviderProfileView> createState() => _ProviderProfileViewState();
}

class _ProviderProfileViewState extends State<ProviderProfileView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> emojis = ['😡', '😐', '☹️', '😊', '😍'];

  Future<Map<String, dynamic>?> _fetchProviderDetails() async {
    try {
      var doc =
          await _firestore.collection('provider').doc(widget.providerId).get();

      QuerySnapshot reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('providerId', isEqualTo: widget.providerId)
          .get();
      List<Map<String, dynamic>> reviews = reviewsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      var providerData = doc.data();
      if (providerData != null) {
        providerData['reviews'] = reviews;
      }

      return providerData;
    } catch (error) {
      print('Error fetching provider details: $error');
      return null;
    }
  }

  Future<List<DocumentSnapshot>> _fetchProviderServices() async {
    try {
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

  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    double totalRating =
        reviews.fold(0, (sum, review) => sum + (review['emojiRating'] ?? 0));
    return reviews.isNotEmpty ? totalRating / reviews.length : 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Provider Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchProviderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Service Provider not found.'));
          }

          var providerData = snapshot.data!;
          var reviews =
              providerData['reviews'] as List<Map<String, dynamic>>? ?? [];
          double averageRating = calculateAverageRating(reviews);

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(providerData, averageRating),
                _buildAboutSection(providerData),
                _buildServicesList(),
                _buildFeedbackSection(reviews),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> providerData, double averageRating) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              providerData['ProfilePic'] ?? 'https://via.placeholder.com/150',
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${providerData['FirstName'] ?? 'Provider Name'} ${providerData['LastName'] ?? ''}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            providerData['Occupation'] ?? 'Occupation',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.solidStar, color: Colors.amber),
              SizedBox(width: 5),
              Text(
                '${averageRating.toStringAsFixed(1)}/5',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> providerData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                providerData['about'] ?? 'No description available.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.clock, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Experience:',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  SizedBox(width: 45,),
                  Text(
                    providerData['experience'] ?? 'N/A' ,
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(

                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.tools, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Skills:',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  SizedBox(width: 85,),

                  Text(
                    ' ${providerData['skills']?.join(', ') ?? 'N/A'}',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchProviderServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
                        'Price: \$${service['Price']}',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Servicecustomerdetail(service: serviceSnapshot),
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

  Widget _buildFeedbackSection(List<Map<String, dynamic>> feedback) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Feedback',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          feedback.isNotEmpty
              ? Column(
                  children: feedback.map((review) {
                    return FutureBuilder<String>(
                      future: _fetchCustomerFullName(review['customerId']),
                      builder: (context, snapshot) {
                        String customerName = snapshot.data ?? 'Customer';
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              customerName,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(review['notes'] ?? 'No review text'),
                            trailing: Text(
                              review['emojiRating'] == null ||
                                      review['emojiRating'] == '0'
                                  ? emojis[
                                      1] // Default to '😐' if no rating or invalid rating
                                  : review['emojiRating'] == '1'
                                      ? emojis[0] // 😡
                                      : review['emojiRating'] == '2'
                                          ? emojis[1] // 😐
                                          : review['emojiRating'] == '3'
                                              ? emojis[2] // ☹️
                                              : review['emojiRating'] == '4'
                                                  ? emojis[3] // 😊
                                                  : review['emojiRating'] == '5'
                                                      ? emojis[4] // 😍
                                                      : emojis[1],
                              // Default to '😐' for any invalid value (fallback)
                              style:
                                  TextStyle(fontSize: 24, color: Colors.blue),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                )
              : Text('No feedback available.'),
        ],
      ),
    );
  }
}
