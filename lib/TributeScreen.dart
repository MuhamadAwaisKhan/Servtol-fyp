import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:servtol/TributeDetailScreen.dart';
import 'package:servtol/util/AppColors.dart';

class TributeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tributes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tributes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No tributes available.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final tributes = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: tributes.length,
            itemBuilder: (context, index) {
              final tribute = tributes[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to detailed tribute screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TributeDetailScreen(
                        name: tribute['name'],
                        occupation: tribute['occupation'],
                        details: tribute['details'],
                        pictureUrl: tribute['pictureUrl'],
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Circular Avatar for Picture
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(tribute['pictureUrl']),
                          backgroundColor: Colors.grey[200],
                        ),
                        SizedBox(width: 16),
                        // Details Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Text(
                                tribute['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              SizedBox(height: 4),
                              // Occupation
                              Text(
                                tribute['occupation'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.blueAccent),
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


