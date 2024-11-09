import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/messagescreen.dart';
import 'package:servtol/util/AppColors.dart';

class ProviderLogScreen extends StatefulWidget {
  final String providerId;

  ProviderLogScreen({required this.providerId});

  @override
  State<ProviderLogScreen> createState() => _ProviderLogScreenState();
}

class _ProviderLogScreenState extends State<ProviderLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('providerId', isEqualTo: widget.providerId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No customers to display.'));
          }

          final customerChats = snapshot.data!.docs;
          print('Fetched customer chats: ${customerChats.length}'); // Debugging

          return ListView.builder(
            itemCount: customerChats.length,
            itemBuilder: (context, index) {
              final chat = customerChats[index];
              final customerId = chat['userId'] ?? '';

              if (customerId.isEmpty) {
                return ListTile(
                  title: Text('Customer ID is missing'),
                );
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('customer')
                    .doc(customerId)
                    .get(),
                builder: (context, customerSnapshot) {
                  if (customerSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading customer details...'),
                    );
                  }

                  if (customerSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading customer data'),
                    );
                  }

                  if (!customerSnapshot.hasData || !customerSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Customer not found'),
                    );
                  }

                  final customerData = customerSnapshot.data!.data() as Map<String, dynamic>;
                  final customerName = "${customerData['FirstName'] ?? 'Unknown'} ${customerData['LastName'] ?? ''}";
                  final customerprofilepic = customerData['ProfilePic'] ?? '';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: (customerprofilepic.isNotEmpty)
                            ? NetworkImage(customerprofilepic)
                            : null,
                        backgroundColor: AppColors.accentColor,
                        child: (customerprofilepic.isEmpty)
                            ? FaIcon(FontAwesomeIcons.user, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        customerName,
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
                              chatWithId: customerId,
                              chatWithName: customerName,
                              chatWithPicUrl: customerprofilepic,
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
