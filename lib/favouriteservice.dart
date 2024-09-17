import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Servicecustomerdetail.dart'; // Correct path for your Servicecustomerdetail import

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<String>>? favoritesFuture;

  @override
  void initState() {
    super.initState();
    favoritesFuture = loadFavorites();
  }

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }

  void removeFavorite(String serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    if (favorites.contains(serviceId)) {
      favorites.remove(serviceId);
      await prefs.setStringList('favorites', favorites);
      setState(() {
        favoritesFuture = loadFavorites(); // Refresh the future to reload data
      });
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
            return CircularProgressIndicator();
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
                        child: CircularProgressIndicator(),
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
                            colors: [Colors.deepPurple, Colors.deepPurple.shade200],
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
