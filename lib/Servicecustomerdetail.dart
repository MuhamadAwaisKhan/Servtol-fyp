import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Servicecustomerdetail extends StatefulWidget {
  final DocumentSnapshot service;

  Servicecustomerdetail({required this.service});

  @override
  State<Servicecustomerdetail> createState() => _ServicecustomerdetailState();
}

class _ServicecustomerdetailState extends State<Servicecustomerdetail> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> serviceData = widget.service.data() as Map<String, dynamic>;
    String providerId = serviceData['providerId'] ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(serviceData['ServiceName'] ?? 'Service Details'),
              background: Image.network(
                serviceData['ImageUrl'] ?? 'default_image_url',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // Provider and service attributes
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('provider').doc(providerId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var providerData = snapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(providerData['ProfilePic'] ?? 'default_profile_pic_url'),
                    ),
                    title: Text(providerData['FirstName'] ?? 'No Provider Name'),

                    subtitle: Text(providerData['Bio'] ?? 'No additional information'),
                    onTap: () {
                      // Navigation to provider profile
                    },
                  );
                },
              ),
              ListTile(
                title: Text('\$${serviceData['Price']}'),
                subtitle: Text('${serviceData['Duration']} min'),
                trailing: Icon(Icons.star, color: Colors.amber),
                leading: Text('${serviceData['Rating']}/5'),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service Attributes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Category: ${serviceData['Category']}', style: TextStyle(fontSize: 16)),
                    Text('Subcategory: ${serviceData['Subcategory']}', style: TextStyle(fontSize: 16)),
                    Text('Service Type: ${serviceData['ServiceType']}', style: TextStyle(fontSize: 16)),
                    Text('Area: ${serviceData['Area']}', style: TextStyle(fontSize: 16)),
                    Text('City: ${serviceData['City']}', style: TextStyle(fontSize: 16)),
                    Text('Province: ${serviceData['Province']}', style: TextStyle(fontSize: 16)),
                    Text('Discount: ${serviceData['Discount']}%', style: TextStyle(fontSize: 16, color: Colors.red)),
                    Text('Wage Type: ${serviceData['WageType']}', style: TextStyle(fontSize: 16)),
                    Text('Time Slot: ${serviceData['TimeSlot']}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              // Reviews Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Text('Customer Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .where('serviceId', isEqualTo: widget.service.id)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('No reviews yet', style: TextStyle(fontSize: 16)),
                    );
                  }
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var review = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(review['reviewerName'] ?? 'Anonymous', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review['comment']),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                Text('${review['rating']} / 5'),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement booking functionality
                  },
                  child: Text('Book Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
