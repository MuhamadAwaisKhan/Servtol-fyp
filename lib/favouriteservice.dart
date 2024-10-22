import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Servicecustomerdetail.dart'; // Correct path for your Servicecustomerdetail import

class FavoritesScreen extends StatefulWidget {
  final String customerId; // Pass the customer ID

  FavoritesScreen({required this.customerId});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<String>>? favoritesFuture;

  @override
  void initState() {
    super.initState();
    favoritesFuture = loadFavorites(widget.customerId); // Pass customerId here
  }

  Future<List<String>> loadFavorites(String customerId) async {
    try {
      // Load favorites from Firestore
      DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance.collection('customers').doc(customerId).get();

      if (customerSnapshot.exists && customerSnapshot.data() != null) {
        Map<String, dynamic>? data = customerSnapshot.data() as Map<String, dynamic>?;
        List<String> favorites = List<String>.from(data?['favorites'] ?? []);

        // Cache the favorites locally using SharedPreferences for quick access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('favorites', favorites);

        return favorites;
      }

      return [];
    } catch (e) {
      print("Error loading favorites: $e");
      return [];
    }
  }


  void removeFavorite(String serviceId) async {
    try {
      // Get the SharedPreferences instance and the current favorites list
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorites') ?? [];

      if (favorites.contains(serviceId)) {
        // Remove the serviceId from the favorites list
        favorites.remove(serviceId);

        // Update the local cache in SharedPreferences
        await prefs.setStringList('favorites', favorites);

        // Update Firestore to remove the serviceId from the customer's favorites
        await FirebaseFirestore.instance.collection('customers').doc(widget.customerId).update({
          'favorites': FieldValue.arrayRemove([serviceId])
        });

        // Update the state to reflect the changes
        setState(() {
          favoritesFuture = loadFavorites(widget.customerId); // Refresh the future to reload data
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from favorites!')),
        );
      }
    } catch (e) {
      print("Error removing favorite: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove favorite')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Favorites", style: TextStyle(fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading)),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<String>>(
        future: favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),

            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String serviceId = snapshot.data![index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('service').doc(serviceId).get(),
                  builder: (context, serviceSnapshot) {
                    if (serviceSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        margin: EdgeInsets.all(8),
                        height: 100,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),

                        ),
                      );
                    } else if (serviceSnapshot.hasError) {
                      return ListTile(
                        title: Text("Error loading service details"),
                      );
                    } else if (serviceSnapshot.hasData && serviceSnapshot.data!.exists) {
                      // Checking if the document exists
                      var doc = serviceSnapshot.data!.data() as Map<String, dynamic>?;
                      if (doc == null) {
                        return ListTile(
                          title: Text("No details available"),
                        );
                      }

                      // Print serviceId and document data for debugging
                      print("Service ID: $serviceId");
                      print("Document Data: $doc");

                      return Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.lightBlueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(doc['ImageUrl'] ?? ''),
                            radius: 25,
                          ),
                          title: Text(
                            doc['ServiceName'] ?? 'No name',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            doc['Category'] ?? 'No category',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "\$" + (doc['Price']?.toString() ?? 'No Price'),
                                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.trashCan),
                                onPressed: () => removeFavorite(serviceId),
                                tooltip: 'Remove from favorites',
                              ),
                            ],
                          ),
                          onTap: () {
                            if (serviceSnapshot.hasData && serviceSnapshot.data != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Servicecustomerdetail(service: serviceSnapshot.data!),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Service details are not available.')),
                              );
                            }
                          },
                        ),
                      );
                    } else {
                      return ListTile(
                        // title: Text("No details available", style: TextStyle(fontFamily: 'Poppins')),
                      );
                    }
                  },

                );
              },
            );
          } else {
            return Center(child: Text("No favorites added yet",style: TextStyle(fontFamily: 'Poppins',)));
          }
        },
      ),
    );
  }
}
