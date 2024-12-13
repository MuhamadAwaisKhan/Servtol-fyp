import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/bookingcustomerdetail.dart';
import 'package:servtol/feedbackscreen.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:timeago/timeago.dart' as timeago;

class customernotification extends StatefulWidget {
  const customernotification({super.key});

  @override
  State<customernotification> createState() => _customernotificationState();
}

class _customernotificationState extends State<customernotification> {
  String? customerId;
  String? customerPicUrl;
  bool isLoading = true;
  List<QueryDocumentSnapshot> combinedNotifications = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      customerId = currentUser?.uid;

      if (customerId != null) {
        customerPicUrl = await fetchCustomerPic(customerId!);
        await fetchNotifications(); // Fetch notifications after user data is fetched
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
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
        return Colors.deepOrange;
      case 'Cancelled':
        return Colors.black54;
      case 'Rejected':
        return Colors.red[800]!;
      case 'Accepted':
        return Colors.green[700]!;
      case 'In Progress':
        return Colors.indigo[700]!;
      case 'Waiting':
        return Colors.blueGrey[800]!;
      case 'Complete':
        return Colors.green[900]!;
      case 'Payment Pending':
        return Colors.deepPurple[900]!;
      case 'On going':
        return Colors.blue[800]!;
      case 'In Process':
        return Colors.brown[800]!;
      case 'Ready to Service':
        return Colors.tealAccent[400]!;
      default:
        return Colors.grey[800]!;
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

  Future<void> fetchNotifications() async {
    try {
      // Query bookingnotifications
      var bookingNotifications = await FirebaseFirestore.instance
          .collectionGroup('bookingnotifications')
          .where('customerId', isEqualTo: customerId)
          .orderBy('timestamp', descending: true)
          .get();

      // Query paymentnotification
      var paymentNotifications = await FirebaseFirestore.instance
          .collectionGroup('paymentnotification')
          .where('customerId', isEqualTo: customerId)
          .orderBy('timestamp', descending: true)
          .get();

      // Query notifications_review
      var reviewNotifications = await FirebaseFirestore.instance
          .collectionGroup('notifications_review')
          .where('customerId', isEqualTo: customerId)
          .orderBy('timestamp', descending: true)
          .get();

      // Combine all notifications into one list
      combinedNotifications = [
        ...bookingNotifications.docs,
        ...paymentNotifications.docs,
        ...reviewNotifications.docs,
      ];

      // Sort notifications by timestamp in descending order
      combinedNotifications.sort((a, b) {
        Timestamp aTime = a['timestamp'];
        Timestamp bTime = b['timestamp'];
        return bTime.compareTo(aTime); // Sort by newest first
      });

      setState(() {}); // Trigger UI update after fetching notifications
    } catch (e) {
      print("Error fetching notifications: $e");
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
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : customerId == null
              ? Center(child: Text('No customer ID found'))
              : combinedNotifications.isEmpty
                  ? Center(child: Text('No notifications'))
                  : ListView.builder(
                      itemCount: combinedNotifications.length,
                      itemBuilder: (context, index) {
                        var notification = combinedNotifications[index];
                        String collectionName =
                            notification.reference.parent.path.split('/').last;
                        bool isPaymentNotification =
                            collectionName == 'paymentnotification';
                        bool isReviewNotification =
                            collectionName == 'notifications_review';

                        var message = isPaymentNotification
                            ? notification['message1'] ?? 'No payment message'
                            : isReviewNotification
                                ? notification['message1'] ??
                                    'No review message'
                                : notification['message1'] ?? 'No message';

                        var timestamp = notification['timestamp'] as Timestamp;

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
                                    ? NetworkImage(customerPicUrl!)
                                    : AssetImage('assets/default_avatar.png')
                                        as ImageProvider,
                                radius: 30,
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isPaymentNotification
                                        ? 'Payment Update'
                                        : isReviewNotification
                                            ? 'Review Request'
                                            : 'Booking Update',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (!isPaymentNotification)
                                    Text(
                                      "${notification['bookingId']}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (isPaymentNotification)
                                    Text(
                                      "Payment Status: ${notification['paymentstatus']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getPaymentStatusColor(
                                            notification['paymentstatus']),
                                      ),
                                    )
                                  else if(isReviewNotification)
                                    Text(
                                      "Feedback Status: ${notification['status']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getStatusColor(
                                            notification['status']),
                                      ),
                                    )
                                  else
                                    Text(
                                      "Payment Status: ${notification['status']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getStatusColor(
                                            notification['status']),
                                      ),
                                    ),

                                  SizedBox(height: 4),
                                  Text(
                                    timeago.format(
                                      timestamp.toDate(),
                                      locale: 'en_short',
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: notification['isRead1'] ?? false
                                  ? Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : Icon(Icons.circle, color: Colors.redAccent),
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection(collectionName)
                                    .doc(notification.id)
                                    .update({'isRead1': true});

                                // Check if it's a review notification
                                if (isReviewNotification) {
                                  String bookingId = notification['bookingId'];

                                  // Navigate to the FeedbackScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FeedbackScreen(bookingId: bookingId), // Assuming FeedbackScreen is imported
                                    ),
                                  );
                                } else {
                                  // If it's not a review notification, continue with booking navigation
                                  String bookingId = notification['bookingId'];

                                  FirebaseFirestore.instance
                                      .collection('bookings')
                                      .doc(bookingId)
                                      .get()
                                      .then((bookingSnapshot) {
                                    if (bookingSnapshot.exists) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookingCustomerDetail(
                                            bookings: bookingSnapshot,
                                          ),
                                        ),
                                      );
                                    } else {
                                      print("Booking not found");
                                    }
                                  }).catchError((error) {
                                    print("Error fetching booking: $error");
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
