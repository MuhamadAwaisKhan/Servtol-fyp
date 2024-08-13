import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Servicecustomerdetail extends StatefulWidget {
  final DocumentSnapshot service;

  Servicecustomerdetail({required this.service});

  @override
  State<Servicecustomerdetail> createState() => _ServicecustomerdetailState();
}

class _ServicecustomerdetailState extends State<Servicecustomerdetail> {
  bool isFavorite = false; // State to track if a service is favorite

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  void checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.service.id);
    });
  }

  Future<bool> toggleFavorite(String serviceId, bool shouldFavorite) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorites') ?? [];
      print("Original Favorites: $favorites");

      if (shouldFavorite) {
        if (!favorites.contains(serviceId)) {
          favorites.add(serviceId);
          print("Added $serviceId to favorites");
        }
      } else {
        if (favorites.contains(serviceId)) {
          favorites.remove(serviceId);
          print("Removed $serviceId from favorites");
        }
      }

      await prefs.setStringList('favorites', favorites);
      print("Updated Favorites: $favorites");
      return true;
    } catch (e) {
      print("Error updating favorites: $e");
      return false;
    }
  }

  Widget build(BuildContext context) {
    Map<String, dynamic> serviceData =
        widget.service.data() as Map<String, dynamic>;
    String providerId = serviceData['providerId'] ?? '';

    ThemeData theme = Theme.of(context);
    Color primaryColor = theme.primaryColor;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                color: isFavorite ? Colors.red : Colors.white,
          onPressed: () async {
            // Assuming serviceData contains a proper 'id' field from Firestore document.
            String? serviceId = widget.service.id;  // Using the document ID directly if not stored in serviceData.

            if (serviceId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unable to toggle favorite: Service ID is missing.'))
              );
              return;
            }

            bool success = await toggleFavorite(serviceId, !isFavorite);
            if (success) {
              setState(() {
                isFavorite = !isFavorite;  // Update the UI based on the new favorite status
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isFavorite ? 'Added to favorites!' : 'Removed from favorites!'))
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to toggle favorite'))
              );
            }
          },
              ),



            ],
              flexibleSpace:FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  serviceData['ServiceName'] ?? 'Service Details',
                  style: theme.textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow( // Bottom-left shadow
                          offset: Offset(-1.5, -1.5),
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                        Shadow( // Top-right shadow
                          offset: Offset(1.5, 1.5),
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                        Shadow( // Outline style shadow
                          offset: Offset(0, 0),
                          color: Colors.black,
                          blurRadius: 8,
                        ),
                      ]
                  ),
                ),
                background: Hero(
                  tag: 'service_image_${serviceData['ServiceName']}',
                  child: Image.network(
                    serviceData['ImageUrl'] ?? 'default_image_url',
                    fit: BoxFit.cover,
                  ),
                ),
              )

          ),
          SliverToBoxAdapter(
              child: buildServiceDetails(
                  context, serviceData, providerId, primaryColor)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implement booking functionality
        },
        label: Text('Book Now'),
        icon: Icon(Icons.check),
        backgroundColor: primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildServiceDetails(BuildContext context,
      Map<String, dynamic> serviceData, String providerId, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${serviceData['Price']}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),

                  Text(' ★ ${serviceData['Rating']}', style: TextStyle(color: Colors.green, fontSize: 20)),

                ],
              ),
              Divider(),
              SizedBox(height: 10),
              Text('Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(serviceData['Description'] ?? 'No description provided.',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: buildAttributeChips(serviceData),
              ),

              SizedBox(height: 20),
              Divider(),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('provider')
                    .doc(providerId)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  var providerData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          providerData['ProfilePic'] ??
                              'default_profile_pic_url'),
                    ),
                    title: Text(providerData['FirstName'] ?? 'No Provider Name',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        providerData['Bio'] ?? 'No additional information',
                        style: TextStyle(color: Colors.grey[700])),

                    onTap: (){

                    }


                  );
                },
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text('Customer Reviews',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .where('serviceId', isEqualTo: widget.service.id)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  if (snapshot.data!.docs.isEmpty)
                    return Text('No reviews yet',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[600]));
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var review = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      return ListTile(
                        title: Text(review['reviewerName'] ?? 'Anonymous',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> buildAttributeChips(Map<String, dynamic> serviceData) {
    List<String> attributes = [
      'Category',
      'Subcategory',
      'ServiceType',
      'Area',
      'City',
      'Province',
      'Discount',
      'WageType',
      'TimeSlot'
    ];
    return attributes
        .map((attribute) => Chip(
              label: Text('${attribute}: ${serviceData[attribute]}'),
              backgroundColor: Colors.deepPurple[100],
            ))
        .toList();
  }
}