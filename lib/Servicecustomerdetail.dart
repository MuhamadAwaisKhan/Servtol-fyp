import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/bookservice.dart';
import 'package:servtol/messagescreen.dart';
import 'package:servtol/providerprofilescreen.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Servicecustomerdetail extends StatefulWidget {
  final DocumentSnapshot service;

  Servicecustomerdetail({required this.service,
    // required String serviceId

  });

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
  // Future<Map<String, dynamic>?> _getProviderDetails(String providerId) async {
  //   final providerDoc = await FirebaseFirestore.instance
  //       .collection('provider')
  //       .doc(providerId)
  //       .get();
  //
  //   return providerDoc.exists ? providerDoc.data() : null;
  // }
  // final providerData = providerSnapshot.data!;
  //
  // final providerName = providerData['FirstName'] ?? 'Unknown Provider';
  // final profilePicUrl = providerData['ProfilePic'];

  void checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.service.id);
    });
  }

  Future<bool> toggleFavorite(
      String serviceId, bool shouldFavorite, String customerId) async {
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

      // Update the favorites locally in SharedPreferences
      await prefs.setStringList('favorites', favorites);

      // Save customer-specific favorites to Firestore
      await FirebaseFirestore.instance
          .collection('customer')
          .doc(customerId)
          .set({
        'favorites': favorites,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other fields

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
                  icon: Icon(
                      isFavorite
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      size: 50),
                  color: isFavorite ? Colors.red : Colors.white,
                  onPressed: () async {
                    // Assuming serviceData contains a proper 'id' field from Firestore document.
                    String? serviceId = widget.service
                        .id; // Using the document ID directly if not stored in serviceData.

                    if (serviceId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Unable to toggle favorite: Service ID is missing.')));
                      return;
                    }

                    // Assuming you have a method to get the current customer's ID
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final User? user = auth.currentUser;
                    String customerId = user?.uid ??
                        ''; // Replace this with actual logic to fetch customer ID

                    bool success = await toggleFavorite(serviceId, !isFavorite,
                        customerId); // Pass the customerId here
                    if (success) {
                      setState(() {
                        isFavorite =
                            !isFavorite; // Update the UI based on the new favorite status
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isFavorite
                              ? 'Added to favorites!'
                              : 'Removed from favorites!')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to toggle favorite')));
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  serviceData['ServiceName'] ?? 'Service Details',
                  style: theme.textTheme.titleLarge!
                      .copyWith(color: Colors.white, shadows: [
                    Shadow(
                      // Bottom-left shadow
                      offset: Offset(-1.5, -1.5),
                      color: Colors.black,
                      blurRadius: 2,
                    ),
                    Shadow(
                      // Top-right shadow
                      offset: Offset(1.5, 1.5),
                      color: Colors.black,
                      blurRadius: 2,
                    ),
                    Shadow(
                      // Outline style shadow
                      offset: Offset(0, 0),
                      color: Colors.black,
                      blurRadius: 8,
                    ),
                  ]),
                ),
                background: Hero(
                  tag: 'service_image_${serviceData['ServiceName']}',
                  child: Image.network(
                    serviceData['ImageUrl'] ?? 'default_image_url',
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          SliverToBoxAdapter(
              child: buildServiceDetails(
                  context, serviceData, providerId, primaryColor)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookServiceScreen(service: widget.service),
            ),
          );
        },
        label: Text('Book Now'),
        icon: Icon(Icons.check),
        backgroundColor: AppColors.customButton,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${serviceData['Price']}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                  FutureBuilder<double>(
                    future: calculateAverageRating(widget.service.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...',
                            style:
                                TextStyle(color: Colors.green, fontSize: 20));
                      } else if (snapshot.hasError) {
                        return Text('Error',
                            style: TextStyle(color: Colors.red, fontSize: 20));
                      } else {
                        double averageRating = snapshot.data ?? 0;
                        return Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.solidStar,
                              color: Colors.amberAccent,
                            ),
                            Text(
                              '  $averageRating',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ],
                        );
                      }
                    },
                  ),
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
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    );
                  }

                  var providerData = snapshot.data!.data() as Map<String, dynamic>;
                  final providerName = providerData['FirstName'] ?? 'Unknown Provider';
                  final profilePicUrl = providerData['ProfilePic'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        providerData['ProfilePic'] ?? 'default_profile_pic_url',
                      ),
                    ),
                    title: Text(
                      providerData['FirstName'] ?? 'No Provider Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      providerData['Bio'] ?? 'No additional information',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    trailing: IconButton(
                      icon: FaIcon(FontAwesomeIcons.solidMessage, color: Colors.blue),
                      onPressed: () {
                        // Navigate to the message screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              chatWithId: providerId,
                              chatWithName: providerName,
                              chatWithPicUrl: profilePicUrl,
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // Navigate to the profile screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProviderProfileView(providerId: providerId),
                        ),
                      );
                    },
                  );
                },
              ),


              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text('Reviews',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold)),
              FutureBuilder<double>(
                future: calculateAverageRating(widget.service.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error loading reviews');
                  } else {
                    double averageRating = snapshot.data ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display average rating
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text('Rating:',
                        //         style: TextStyle(fontWeight: FontWeight.bold)),
                        //     Text('$averageRating / 5',
                        //         style: TextStyle(color: Colors.green, fontSize: 20)),
                        //   ],
                        // ),

                        // StreamBuilder to fetch and display reviews
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('reviews')
                              .where('serviceId', isEqualTo: widget.service.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              );
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return Text('No reviews yet',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]));
                            }

                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var review = snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                                String? customerId = review['customerId'];

                                // Fetch customer details using the customerId
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('customer')
                                      .doc(customerId)
                                      .get(),
                                  builder: (context, customerSnapshot) {
                                    if (!customerSnapshot.hasData) {
                                      return ListTile(
                                          title: Text(
                                              'Loading customer details...'));
                                    }

                                    if (customerSnapshot.data == null ||
                                        customerSnapshot.data!.data() == null) {
                                      return ListTile(
                                          title: Text('Customer not found'));
                                    }

                                    var customerData = customerSnapshot.data!
                                        .data() as Map<String, dynamic>;
                                    String reviewerName =
                                        customerData['FirstName'] ??
                                            'Anonymous';
                                    String reviewerName1 =
                                        customerData['LastName'] ?? 'Anonymous';

                                    return Card(
                                      color: Colors.indigo,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      elevation: 4.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Text(reviewerName,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(
                                                  width: 05,
                                                ),
                                                Text(reviewerName1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 122,
                                              height: 15,
                                            ),
                                            Row(
                                              children: [
                                                Icon(FontAwesomeIcons.solidStar,
                                                    color: Colors.amber),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  '${review['emojiRating']}.0/ 5',
                                                  style: TextStyle(
                                                    // color: Colors.green,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                review['notes'] ??
                                                    'No notes provided',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Poppins',
                                                )),
                                          ],
                                        ),
                                        isThreeLine: true,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        )
                      ],
                    );
                  }
                },
              )
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
      'Duration'
    ];
    return attributes
        .map((attribute) => Chip(
              label: Text(
                '${attribute}: ${serviceData[attribute]}',
                style: TextStyle(
                    color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
              ),
              backgroundColor: Colors.indigo,
            ))
        .toList();
  }

  Future<double> calculateAverageRating(String serviceId) async {
    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('serviceId', isEqualTo: serviceId)
        .get();

    double totalRating = 0;
    int reviewCount = 0;

    for (var reviewDoc in reviewsSnapshot.docs) {
      var reviewData = reviewDoc.data() as Map<String, dynamic>;
      totalRating += reviewData['emojiRating'] ?? 0;
      reviewCount++;
    }

    return reviewCount > 0 ? totalRating / reviewCount : 0;
  }
}
