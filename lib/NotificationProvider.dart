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
  List<QueryDocumentSnapshot> combinedNotifications = [];
  String? customerPicUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      providerId = currentUser?.uid;

      if (providerId != null) {
        customerPicUrl = await fetchCustomerPic(providerId!);
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

  Future<String?> fetchCustomerPic(String providerId) async {
    try {
      DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
          .collection('provider')
          .doc(providerId)
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
          .where('providerId', isEqualTo: providerId)
          .orderBy('timestamp', descending: true)
          .get();

      // Query paymentnotification
      var paymentNotifications = await FirebaseFirestore.instance
          .collectionGroup('paymentnotification')
          .where('providerId', isEqualTo: providerId)
          .orderBy('timestamp', descending: true)
          .get();

      // Combine booking and payment notifications into one list
      combinedNotifications = [
        ...bookingNotifications.docs,
        ...paymentNotifications.docs,
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
          : providerId == null
          ? Center(child: Text('No customer ID found'))
          : combinedNotifications.isEmpty
          ? Center(child: Text('No notifications'))
          : ListView.builder(
        itemCount: combinedNotifications.length,
        itemBuilder: (context, index) {
          var notification = combinedNotifications[index];
          String collectionName = notification.reference.parent.path.split('/').last;
          bool isPaymentNotification = collectionName == 'paymentnotification';

          var message = isPaymentNotification
              ? notification['message'] ?? 'No payment message'
              : notification['message'] ?? 'No booking message';

          var timestamp = notification['timestamp'] as Timestamp;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                  radius: 30,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isPaymentNotification
                          ? 'Payment Update'
                          : 'Booking Update',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (!isPaymentNotification)
                      Text(
                        "${notification['bookingId']}",
                        style: TextStyle(
                          fontSize: 16,
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
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    if (isPaymentNotification)
                      Text(
                        "Payment Status: ${notification['paymentstatus']}",
                        style: TextStyle(
                          fontSize: 14,
                          color: _getPaymentStatusColor(notification['paymentstatus']),
                        ),
                      )
                    else
                      Text(
                        "Booking Status: ${notification['status']}",
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(notification['status']),
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
                trailing: notification['isRead'] ?? false
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.circle, color: Colors.redAccent),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection(collectionName)
                      .doc(notification.id)
                      .update({'isRead': true});

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
                          builder: (context) => bookingproviderdetail(
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
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
