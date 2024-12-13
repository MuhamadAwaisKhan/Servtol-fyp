import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/messagescreen.dart';
import 'package:servtol/util/AppColors.dart';

class CustomerLogScreen extends StatefulWidget {
  final Function onBackPress;

  const CustomerLogScreen({Key? key, required this.onBackPress}) : super(key: key);

  @override
  State<CustomerLogScreen> createState() => _CustomerLogScreenState();
}

class _CustomerLogScreenState extends State<CustomerLogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text("Please log in to see your messages."),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
              final otherUserId = (data['participants'] as List).firstWhere(
                    (id) => id != currentUser.uid,
                orElse: () => null,
              );
              final lastMessage = data['lastMessage'] ?? "No messages yet";

              if (otherUserId == null) {
                return const ListTile(title: Text("Unknown User"));
              }

              // Use FutureBuilder to handle async unread message count
              return FutureBuilder<int>(
                future: _getUnreadMessagesCount(otherUserId),
                builder: (context, unreadMessagesSnapshot) {
                  if (unreadMessagesSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  if (unreadMessagesSnapshot.hasError) {
                    return const ListTile(title: Text("Error fetching unread count"));
                  }

                  final unreadMessagesCount = unreadMessagesSnapshot.data ?? 0;

                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('provider').doc(otherUserId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(title: Text("Loading..."));
                      }

                      if (userSnapshot.hasError || !userSnapshot.hasData) {
                        return const ListTile(
                          title: Text("Error loading provider data"),
                        );
                      }

                      final providerData = userSnapshot.data!.data()
                      as Map<String, dynamic>? ?? {};
                      final providerName =
                          providerData['FirstName'] ?? 'Unknown Provider';
                      final profilePicUrl = providerData['ProfilePic'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                            providerName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          subtitle: unreadMessagesCount > 0
                              ? Text(
                            'Unread messages: $unreadMessagesCount',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.secondaryTextColor,
                            ),
                          )
                              : const Text(
                            'Tap to chat',
                            style: TextStyle(
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
                                  chatWithId: otherUserId,
                                  chatWithName: providerName,
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
          );
        },
      ),
    );
  }

  // Function to get unread messages count for a specific provider
  Future<int> _getUnreadMessagesCount(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return 0;
    }

    final querySnapshot = await _firestore
        .collection('conversations')
        .doc('${currentUser.uid}_$otherUserId')
        .collection('messages')
        .where('read', isEqualTo: false)
        .get();

    return querySnapshot.size;
  }
}