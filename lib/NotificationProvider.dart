import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/bookingproviderdetail.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:rxdart/rxdart.dart';

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
          .collection('provider')
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
      case 'Ready to Service':
        return Colors.tealAccent[400]!;


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
          ? Center(child: Text('No customer ID found'))
          : StreamBuilder<List<QuerySnapshot>>(
        stream: CombineLatestStream.list([
          FirebaseFirestore.instance
              .collection('notifications')
              .where('providerId', isEqualTo: providerId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          FirebaseFirestore.instance
              .collection('paymentnotification')
              .where('providerId', isEqualTo: providerId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Combine both notification and payment notifications into one list
          var notifications = snapshot.data![0].docs;
          var paymentNotifications = snapshot.data![1].docs;

          // Combine both lists into a single list and sort by timestamp
          var combinedNotifications = [
            ...notifications,
            ...paymentNotifications
          ]..sort((a, b) {
            Timestamp timestampA = a['timestamp'];
            Timestamp timestampB = b['timestamp'];
            // Handle null timestamps by placing them at the end
            // if (timestampA == null && timestampB == null) return 0;
            // if (timestampA == null) return 1;
            // if (timestampB == null) return -1;
            return timestampB
                .compareTo(timestampA); // Descending order
          });

          if (combinedNotifications.isEmpty) {
            return Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: combinedNotifications.length,
            itemBuilder: (context, index) {
              var notification = combinedNotifications[index];

              // Check if the notification is from `notifications` or `paymentnotification`
              bool isPaymentNotification =
              paymentNotifications.contains(notification);

              var message = isPaymentNotification
                  ? notification['message'] ?? 'No payment message'
                  : notification['message'] ?? 'No message';

              var timestamp = notification['timestamp'] as Timestamp;

              return FutureBuilder<String?>(
                future: fetchCustomerPic(providerId!),
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
                                isPaymentNotification
                                    ? 'Payment Update'
                                    : 'Booking Update',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              // if (!isPaymentNotification)
                              Text(
                                "#${notification['bookingId']}",
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
                              if (isPaymentNotification)
                                Text(
                                  "Payment Status: ${notification['paymentstatus']}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getPaymentStatusColor(
                                        notification[
                                        'paymentstatus']),
                                  ),
                                )
                              else
                                Text(
                                  "Booking Status: ${notification['status']}",
                                  style: TextStyle(
                                    fontSize: 14,
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
                          trailing: notification['isRead'] ?? false
                              ? Icon(Icons.check_circle,
                              color: Colors.green)
                              : Icon(Icons.circle,
                              color: Colors.redAccent),
                          onTap: () {
                            FirebaseFirestore.instance
                                .collection(isPaymentNotification
                                ? 'paymentnotification'
                                : 'notifications')
                                .doc(notification.id)
                                .update({'isRead1': true});

                            // Fetch the booking ID, handling both notification types
                            String bookingId = isPaymentNotification
                                ? notification[
                            'bookingId'] // Assuming payment notifications also have a bookingId
                                : notification['bookingId'];

                            FirebaseFirestore.instance
                                .collection('bookings')
                                .doc(bookingId)
                                .get()
                                .then((bookingSnapshot) {
                              if (bookingSnapshot.exists) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        bookingproviderdetail(
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
