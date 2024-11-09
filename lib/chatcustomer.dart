import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/messagescreen.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessageLogCustomerScreen extends StatefulWidget {
  final Function onBackPress;

  MessageLogCustomerScreen({Key? key, required this.onBackPress}) : super(key: key);

  @override
  State<MessageLogCustomerScreen> createState() => _MessageLogCustomerScreenState();
}

class _MessageLogCustomerScreenState extends State<MessageLogCustomerScreen> {
  Stream<QuerySnapshot<Object?>> _messageStream() {
    return FirebaseFirestore.instance
        .collection('conversations')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> _getProviderDetails(String providerId) async {
    final providerDoc = await FirebaseFirestore.instance
        .collection('provider')
        .doc(providerId)
        .get();

    return providerDoc.exists ? providerDoc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service Providers',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => widget.onBackPress(),
        // ),
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: _messageStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No providers found.'));
          }

          final conversations = snapshot.data!.docs.map((doc) {
            return {
              'id': doc.id,
              'providerId': doc['providerId'],
            };
          }).toList();

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final providerId = conversations[index]['providerId'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getProviderDetails(providerId),
                builder: (context, providerSnapshot) {
                  if (!providerSnapshot.hasData) {
                    return ListTile(
                      title: Text("Loading..."),
                    );
                  }

                  final providerData = providerSnapshot.data!;
                  final providerName = providerData['FirstName'] ?? 'Unknown Provider';
                  final profilePicUrl = providerData['ProfilePic'];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: profilePicUrl != null
                            ? NetworkImage(profilePicUrl)
                            : null,
                        backgroundColor: AppColors.accentColor,
                        child: profilePicUrl == null
                            ? FaIcon(FontAwesomeIcons.user, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        providerName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        'Tap to chat',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      trailing: Icon(
                        FontAwesomeIcons.message,
                        color: AppColors.primaryColor,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              chatWithId: providerId,                 // Pass the provider's ID here
                              chatWithName: providerName,             // Pass the provider's name here
                              chatWithPicUrl: profilePicUrl,          // Pass the provider's profile picture URL
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
