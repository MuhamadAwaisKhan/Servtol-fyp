import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/messagescreen.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessageLogProviderScreen extends StatefulWidget {
  final String providerId;

  const MessageLogProviderScreen({Key? key, required this.providerId})
      : super(key: key);

  @override
  State<MessageLogProviderScreen> createState() =>
      _MessageLogProviderScreenState();
}

class _MessageLogProviderScreenState extends State<MessageLogProviderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Please log in to see your messages.",
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Customers',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('conversations')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error fetching conversations."),
            );
          }

          final conversations = snapshot.data?.docs ?? [];
          if (conversations.isEmpty) {
            return const Center(
              child: Text("No conversations found."),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final data = conversations[index].data() as Map<String, dynamic>;
              final customerId = (data['participants'] as List).firstWhere(
                    (id) => id != currentUser.uid,
                orElse: () => null,
              );
              final lastMessage = data['lastMessage'] ?? "No messages yet";

              if (customerId == null) {
                return const ListTile(title: Text("Unknown User"));
              }

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('customer').doc(customerId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return const ListTile(
                      title: Text("Error loading customer data."),
                    );
                  }

                  final customerData = userSnapshot.data!.data()
                  as Map<String, dynamic>? ??
                      {};
                  final customerName =
                      customerData['FirstName'] ?? 'Unknown Customer';
                  final profilePicUrl = customerData['ProfilePic'];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
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
                            ? const FaIcon(
                          FontAwesomeIcons.user,
                          color: Colors.white,
                        )
                            : null,
                      ),
                      title: Text(
                        customerName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        lastMessage,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      trailing: Icon(
                        FontAwesomeIcons.solidMessage,
                        color: AppColors.primaryColor,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              chatWithId: customerId,
                              chatWithName: customerName,
                              chatWithPicUrl: profilePicUrl,
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
