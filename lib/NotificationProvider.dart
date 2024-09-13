import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/bookingproviderdetail.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationProvider extends StatefulWidget {
  const NotificationProvider({
    super.key,
  });

  @override
  State<NotificationProvider> createState() => _NotificationProviderState();
}

class _NotificationProviderState extends State<NotificationProvider> {
  String? providerId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProviderId();
  }

  Future<void> fetchProviderId() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      setState(() {
        providerId = currentUser?.uid;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching providerId: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> fetchCustomerPic(String customerId) async {
    try {
      DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
          .collection('customer')
          .doc(customerId)
          .get();

      if (customerSnapshot.exists) {
        return customerSnapshot['ProfilePic'];
      }
    } catch (e) {
      print("Error fetching customer picture: $e");
    }
    return null;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors
            .deepOrange; // Darker orange that stands out on a light background.

      case 'Cancelled':
        return Colors
            .black54; // A dark grey to indicate a disabled or inactive state.

      case 'Rejected':
        return Colors
            .red[800]!; // A dark red to clearly indicate a negative status.

      case 'Accepted':
        return Colors
            .green[700]!; // A darker shade of green for better visibility.

      case 'In Progress':
        return Colors
            .indigo[700]!; // A deep indigo for a sense of ongoing work.

      case 'Waiting':
        return Colors.blueGrey[
        800]!; // Dark blue-grey to suggest a paused or waiting state.

      case 'Complete':
        return Colors
            .green[900]!;
      case 'Payment Pending':
        return Colors
            .deepPurple[900]!; // A dark green to represent finality and success.

      case 'On going':
        return Colors.blue[800]!;
      case 'In Process':
        return Colors
            .brown[800]!; // A dark blue that conveys stability and continuity.

      default:
        return Colors
            .grey[800]!; // Dark grey for any unknown or undefined statuses.
    }
  }


  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;

      case 'Paid by Card':
        return Colors.green;
      case 'OnCash':
        return Colors.teal;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 19,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : providerId == null
              ? Center(child: Text('No provider ID found'))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('providerId', isEqualTo: providerId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var notifications = snapshot.data!.docs;

                    if (notifications.isEmpty) {
                      return Center(child: Text('No notifications'));
                    }

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        var notification = notifications[index];
                        var customerId = notification['customerId'];
                        var message = notification['message'] ?? 'No message';
                        var bookingId = notification['bookingId'];
                        var serviceState = notification['status'];
                        var timestamp = notification['timestamp'] as Timestamp;

                        return FutureBuilder<String?>(
                          future: fetchCustomerPic(customerId),
                          builder: (context, customerPicSnapshot) {
                            if (customerPicSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            var customerPicUrl = customerPicSnapshot.data;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                    contentPadding: EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      backgroundImage: customerPicUrl != null
                                          ? NetworkImage(customerPicUrl)
                                          : AssetImage(
                                                  'assets/default_avatar.png')
                                              as ImageProvider,
                                      radius: 30,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Booking Update',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          "#$bookingId",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Text(
                                          message,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                           "Status: $serviceState",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _getStatusColor(
                                                serviceState), // Apply color scheme here
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          timeago.format(
                                            (timestamp as Timestamp).toDate(),
                                            locale: 'en_short',
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: notification['isRead']
                                        ? Icon(Icons.check_circle,
                                            color: Colors.green)
                                        : Icon(Icons.circle,
                                            color: Colors.redAccent),
                                    onTap: () {
                                      FirebaseFirestore.instance
                                          .collection('notifications')
                                          .doc(notification.id)
                                          .update({'isRead': true});
                                      FirebaseFirestore.instance
                                          .collection(
                                              'bookings') // Assuming your bookings are stored in a 'bookings' collection
                                          .doc(
                                              bookingId) // Use the bookingId from the notification
                                          .get()
                                          .then((bookingSnapshot) {
                                        if (bookingSnapshot.exists) {
                                          // Navigate to the booking details page with the fetched booking document
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  bookingproviderdetail(
                                                bookings:
                                                    bookingSnapshot, // Pass the entire DocumentSnapshot
                                              ),
                                            ),
                                          );
                                        } else {
                                          print("Booking not found");
                                        }
                                      }).catchError((error) {
                                        print("Error fetching booking: $error");
                                      });
                                    }),
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
