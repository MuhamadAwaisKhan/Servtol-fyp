import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutCEOScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          "About",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color:AppColors.heading ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('about_ceo')
            .doc('ceo_info')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "An error occurred. Please try again later.",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No details available about the CEO at this moment.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          var data = snapshot.data!;
          final facebookLink = data['facebook'] ?? '';
          final instagramLink = data['instagram'] ?? '';
          final linkedinLink = data['linkedin'] ?? '';
          final githubinLink = data['github'] ?? '';

          // Default placeholders for missing fields
          final profilePicUrl = data['profile_pic_url'] ??
              "https://via.placeholder.com/150"; // Placeholder image URL
          final name = data['name'] ?? "Name not available";
          final title = data['title'] ?? "Title not available";
          final visionMission = data['vision_mission'] ?? "Vision & Mission not available.";
          final journey = data['journey'] ?? "Journey details are not available.";
          final achievements = data['achievements'] as List? ?? ["No achievements listed."];
          final message = data['message'] ?? "No message provided by the founder.";

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  GestureDetector(
                    onTap: () {
                      if (profilePicUrl != "https://via.placeholder.com/150") {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Image.network(profilePicUrl),
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[300], // Optional background color
                        child: ClipOval(
                          child: Image.network(
                            profilePicUrl,
                            width: 350, // Diameter of the CircleAvatar
                            height: 350, // Diameter of the CircleAvatar
                            fit: BoxFit.contain, // Ensures the image fits the circle
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person, // Placeholder icon if image fails to load
                                size: 70,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),


                  SizedBox(height: 16),
                  // Name and Title
                  Center(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ),
                  Center(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Vision & Mission
                  _buildSectionHeader(
                    title: "Vision & Mission",
                    icon: FontAwesomeIcons.bullseye,
                  ),
                  Text(
                    visionMission,
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  // Journey
                  _buildSectionHeader(
                    title: "Journey",
                    icon: FontAwesomeIcons.shoePrints,
                  ),
                  Text(
                    journey,
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  // Key Achievements
                  _buildSectionHeader(
                    title: "Key Achievements",
                    icon: FontAwesomeIcons.trophy,
                  ),
                  ...List<Widget>.from(achievements.map(
                        (achievement) => ListTile(
                      leading: Icon(
                        Icons.check_circle_outline,
                        color:AppColors.heading,
                      ),
                      title: Text(
                        achievement,
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
                  )),
                  SizedBox(height: 20),
                  // Message from the Founder
                  _buildSectionHeader(
                    title: "Message from the Founder",
                    icon: FontAwesomeIcons.quoteRight,
                  ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  SizedBox(height: 20),

                  // Social Media Links Section
                  _buildSectionHeader(
                      title: "Social Media", icon: FontAwesomeIcons.shareNodes),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Facebook
                      if (facebookLink.isNotEmpty)
                        IconButton(
                          icon: Icon(FontAwesomeIcons.facebook,
                              color: Colors.blue[700]),
                          onPressed: () => _launchURL(facebookLink),
                        ),

                      // Instagram
                      if (instagramLink.isNotEmpty)
                        IconButton(
                          icon: Icon(FontAwesomeIcons.instagram,
                              color: Colors.pink),
                          onPressed: () => _launchURL(instagramLink),
                        ),
                      // Github
                      if (githubinLink.isNotEmpty)
                        IconButton(
                          icon: Icon(FontAwesomeIcons.github,
                              color: Colors.black),
                          onPressed: () => _launchURL(githubinLink),
                        ),

                      // LinkedIn
                      if (linkedinLink.isNotEmpty)
                        IconButton(
                          icon: Icon(FontAwesomeIcons.linkedin,
                              color: Colors.blue[800]),
                          onPressed: () => _launchURL(linkedinLink),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.heading, size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.heading),
        ),
      ],
    );
  }
}
// Helper function to launch URLs
Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');

  }
}
