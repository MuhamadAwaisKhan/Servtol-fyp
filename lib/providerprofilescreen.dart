import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/util/AppColors.dart';

class providerprofileview extends StatefulWidget {
  String providerId;
   providerprofileview({super.key, required this.providerId});

  @override
  State<providerprofileview> createState() => _providerprofileviewState();
}

class _providerprofileviewState extends State<providerprofileview> {


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _fetchProviderDetails() async {
    try {
      var doc = await _firestore.collection('provider').doc(widget.providerId).get();
      return doc.exists ? doc.data() : null;
    } catch (error) {
      print('Error fetching provider details: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Provider Profile',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
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
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(providerData),
                _buildAboutSection(providerData),
                _buildServicesList(providerData['services']),
                _buildFeedbackSection(providerData['feedback']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> providerData) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(providerData['profilePicture'] ?? 'default-image-url'),
          ),
          SizedBox(height: 10),
          Text(
            providerData['name'] ?? 'Provider Name',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            providerData['occupation'] ?? 'Occupation',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.white70),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 5),
              Text(
                providerData['rating']?.toStringAsFixed(1) ?? '0.0',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> providerData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            providerData['about'] ?? 'No description available.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(FontAwesomeIcons.clock, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Experience: ${providerData['experience']} years',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ],
          ),
          Row(
            children: [
              Icon(FontAwesomeIcons.tools, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Skills: ${providerData['skills']?.join(', ') ?? 'N/A'}',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<dynamic>? services) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services Provided',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (services != null && services.isNotEmpty)
            ...services.map((service) {
              return ListTile(
                leading: Lottie.asset('assets/animations/${service['animationFile']}', width: 60),
                title: Text(
                  service['name'] ?? 'Service',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Price: \$${service['price']}',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                onTap: () {
                  // Handle service detail navigation here
                },
              );
            }).toList()
          else
            Text('No services available.'),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(List<dynamic>? feedback) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Feedback',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (feedback != null && feedback.isNotEmpty)
            ...feedback.map((review) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.blueAccent),
                  title: Text(
                    review['customerName'] ?? 'Customer',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review['comment'] ?? 'No comments', style: TextStyle(fontFamily: 'Poppins')),
                      SizedBox(height: 5),
                      Row(
                        children: List.generate(
                          5,
                              (index) => Icon(
                            index < review['rating'] ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList()
          else
            Text('No customer feedback available.'),
        ],
      ),
    );
  }
}
