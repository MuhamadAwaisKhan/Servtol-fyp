import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';
import 'package:servtol/NotificationProvider.dart';
import 'package:servtol/ServiceScreenDetail.dart';
import 'package:servtol/bookingprovider.dart';
import 'package:servtol/bookingproviderdetail.dart';
import 'package:servtol/chatprovider.dart';
import 'package:servtol/monthlyearning.dart';
import 'package:servtol/servicescreenprovider.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:servtol/wallethistory.dart';

class HomeProvider extends StatefulWidget {
  Function onBackPress;

  HomeProvider({super.key, required this.onBackPress});

  @override
  State<HomeProvider> createState() => _HomeProviderState();
}

class _HomeProviderState extends State<HomeProvider> {
  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Initial loading text
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userName = 'Loading...';
  String? providerPicUrl;

  int bookingCount = 0;
  int serviceCount = 0;
  String providerId = ''; // Declare providerId here

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    listenForUnreadNotifications();
    _fetchBookingCount();
    _fetchServiceCount();
  }

  Future<void> fetchUserInfo() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _userName = 'No user logged in';
        providerPicUrl = null;
      });
      return; // Exit if no user is logged in
    }

    final userEmail = currentUser.email;
    if (userEmail == null) {
      setState(() {
        _userName = 'User email is not available';
        providerPicUrl = null;
      });
      return; // Exit if email is null
    }

    try {
      // Query Firestore for a document where the 'Email' field matches the user's email
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('provider')
          .where('Email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _userName = 'No matching user found in Firestore';
          providerPicUrl = null;
        });
      } else {
        Map<String, dynamic> userData = snapshot.docs.first.data();
        String? name = userData['FirstName'] as String?;
        String? profilePic = userData['ProfilePic'] as String?;

        setState(() {
          _userName = name ?? 'Name not available';
          providerPicUrl = profilePic; // Can be null if not available
          providerId = snapshot.docs.first.id; // Store providerId here
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Failed to fetch user data: $e';
        providerPicUrl = null;
      });
      print(e); // Print the error to the console for debugging
    }
  }

  int unreadCount = 0;

  // Function to listen for unread notifications
  void listenForUnreadNotifications() {
    // Listen to notifications collection
    FirebaseFirestore.instance
        .collection('bookingnotifications')
        .where('providerId', isEqualTo: currentUser?.uid)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true) // Add orderBy clause
        .snapshots()
        .listen((snapshot) {
      // Update unread count for notifications
      int notificationUnreadCount = snapshot.docs.length;

      // Listen to paymentnotification collection
      FirebaseFirestore.instance
          .collection('paymentnotification')
          .where('providerId', isEqualTo: currentUser?.uid)
          .where('isRead', isEqualTo: false)
          .orderBy('timestamp', descending: true) // Add orderBy clause
          .snapshots()
          .listen((snapshot) {
        // Update unread count for payment notifications
        int paymentNotificationUnreadCount = snapshot.docs.length;

        // Combine unread counts and update state
        setState(() {
          unreadCount =
              notificationUnreadCount + paymentNotificationUnreadCount;
        });
      });
    });
  }

  Future<void> _fetchBookingCount() async {
    if (currentUser != null) {
      QuerySnapshot bookingSnapshot = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: currentUser!.uid)
          .get();
      setState(() {
        bookingCount = bookingSnapshot.size;
      });
    }
  }

  Future<void> _fetchServiceCount() async {
    if (currentUser != null) {
      QuerySnapshot serviceSnapshot = await _firestore
          .collection('service')
          .where('providerId', isEqualTo: currentUser!.uid)
          .get();
      setState(() {
        serviceCount = serviceSnapshot.size;
      });
    }
  }

  Stream<QuerySnapshot> _fetchIncomingBookings() {
    // Fetch bookings where providerId matches the current provider's ID
    return _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: currentUser?.uid)
        .where('status', isEqualTo: 'Pending')
        .snapshots();
  }

  Future<Map<String, dynamic>> fetchBookingDetails(
      Map<String, dynamic> bookingData) async {
    try {
      Map<String, dynamic> result = {};

      var providerData =
          await fetchDocument('provider', bookingData['providerId']);
      var customerData =
          await fetchDocument('customer', bookingData['customerId']);
      var couponData = await fetchDocument('coupons', bookingData['couponId']);
      var serviceData =
          await fetchDocument('service', bookingData['serviceId']);

      result['provider'] = providerData ?? {};
      result['coupon'] = couponData ?? {};
      result['service'] = serviceData ?? {};
      result['customer'] = customerData ?? {};
      result['bookingId'] = bookingData['bookingId'];
      result['status'] = bookingData['status'];
      result['date'] = bookingData['date'];
      result['time'] = bookingData['time'];
      result['total'] = bookingData['total'];
      result['address'] = bookingData['address'];
      result['discount'] = bookingData['discount'];
      result['quantity'] = bookingData['quantity'];

      return result;
    } catch (e) {
      print("Error fetching booking details: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>?> fetchDocument(
      String collection, String documentId) async {
    try {
      var snapshot =
          await _firestore.collection(collection).doc(documentId).get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data();
      } else {
        print("Document not found in $collection with ID $documentId");
        return null;
      }
    } catch (e) {
      print("Failed to fetch document from $collection: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Service Provider Home",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
        leading: Icon(size: 0.0, Icons.arrow_back),
        actions: <Widget>[
          IconButton(
            icon: FaIcon(FontAwesomeIcons.message),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessageLogProviderScreen(
                        providerId: providerId,
                      )),
            ),
          ),
          StreamBuilder<List<QuerySnapshot>>(
            stream: CombineLatestStream.list([
              FirebaseFirestore.instance
                  .collection('bookingnotifications')
                  .where('providerId', isEqualTo: currentUser?.uid)
                  .where('isRead', isEqualTo: false)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              FirebaseFirestore.instance
                  .collection('paymentnotification')
                  .where('providerId', isEqualTo: currentUser?.uid)
                  .where('isRead', isEqualTo: false)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),

            ]),
            builder: (context, snapshot) {
              int unreadCount = 0;

              if (snapshot.hasData) {
                // Combine unread counts from all three collections
                unreadCount = snapshot.data![0].docs.length + // notifications
                    snapshot.data![1].docs.length; // payment notifications
                //+ snapshot.data![2].docs.length;  // review notifications
              }

              return Stack(
                children: [
                  IconButton(
                    iconSize: 30,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    icon: FaIcon(FontAwesomeIcons.bell),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationProvider(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            providerInfoSection(),
            greetingSection(),
            earningsSection(),
            customButtonSection(),
            monthlyRevenueChart(),
            upcomingBookings(),
            servicesList(),
          ],
        ),
      ),
    );
  }

  Widget providerInfoSection() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 00.0),
            child: Text("Hello  $_userName  ",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading)),
          ),
          SizedBox(width: 10),
          providerPicUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(providerPicUrl!),
                  radius: 30,
                )
              : CircleAvatar(
                  child: Icon(Icons.account_circle, size: 60),
                  radius: 30,
                ),
        ],
      );

  Widget greetingSection() => Column(
        children: [
          SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.only(right: 158.0),
            child: Text("Welcome back!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.5,
                  // shadows: [
                  //   Shadow(
                  //     color: Colors.black.withOpacity(0.2),
                  //     blurRadius: 2,
                  //     offset: Offset(1, 1),
                  //   ),
                  // ],
                )),
          ),
          SizedBox(height: 5),
        ],
      );

  Widget earningsSection() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(FontAwesomeIcons.wallet, color: Colors.black, size: 28),
            Text("Today's Earning:",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.heading)),
            Text("\u20A8 712.90",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey)),
          ],
        ),
      );

  Widget customButtonSection() => Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              uihelper.CustomButton1(
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreenWidget(
                        onBackPress: widget.onBackPress,
                      ),
                    ),
                  );
                },
                "  Bookings            ",
                50,
                170,
                icon:
                    FaIcon(FontAwesomeIcons.calendarCheck, color: Colors.white),
              ),
              uihelper.CustomButton1(
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceScreenWidget(
                        onBackPress: widget.onBackPress,
                      ),
                    ),
                  );
                },
                "Total Services ",
                50,
                170,
                icon: FaIcon(FontAwesomeIcons.gears, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              uihelper.CustomButton1(
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyEarningsScreen(),
                    ),
                  );
                },
                "Monthly Earning ",
                50,
                170,
                icon: FaIcon(FontAwesomeIcons.rupeeSign, color: Colors.white),
              ),
              uihelper.CustomButton1(
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WalletHistoryScreen()),
                  );
                },
                "Wallet History ",
                50,
                170,
                icon:
                    FaIcon(FontAwesomeIcons.googleWallet, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      );

  Widget monthlyRevenueChart() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 112.0),
            child: Text(
              "Monthly Revenue",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.heading,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),
          // Chart Container
          Center(
            child: Container(
              width: 330,
              height: 230,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1000,
                    // Grid line every 1000 PKR
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value >= 1000) {
                            return Text(
                              '\u20A8${(value / 1000).toStringAsFixed(0)}K',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            );
                          } else {
                            return Text(
                              '\u20A8${value.toInt()}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Define the months list here
                          const months = [
                            "Jan",
                            "Feb",
                            "Mar",
                            "Apr",
                            "May",
                            "Jun",
                            "July",
                            "Aug",
                            "Sep",
                            "Oct",
                            "Nov",
                            "Dec"
                          ];

                          // 1. Calculate the interval between x-axis values
                          double interval =
                              (meta.max - meta.min) / (months.length - 1);

                          // 2. Determine the index based on the value and interval
                          int index = (value / interval).round();

                          // 3. Return the corresponding month
                          if (index >= 0 && index < months.length) {
                            return Text(
                              months[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            );
                          } else {
                            return const SizedBox
                                .shrink(); // Return an empty widget if out of range
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                        color: Colors.blueGrey), // Changed border color
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 5000),
                        const FlSpot(1, 6500),
                        const FlSpot(2, 2500),
                        const FlSpot(3, 7000),
                        const FlSpot(4, 4800),
                        const FlSpot(5, 2000),
                        const FlSpot(6, 8800),
                      ],
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Colors.indigo, Colors.blueAccent],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.withOpacity(0.3),
                            Colors.blueAccent.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );

  Widget upcomingBookings() => Column(children: [
        Text("Upcoming Booking",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AppColors.heading)),
        SizedBox(height: 15),
        Container(
            width: 330,
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.heading.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.heading, width: 3),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: _fetchIncomingBookings(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Incoming bookings.'));
                }

                return Column(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    var bookingData = document.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12.0),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: SizedBox(
                                height: 70, // Specifies the height of the image
                                width: 70, // Specifies the width of the image
                                child: Image.network(
                                  bookingData['ImageUrl'] ??
                                      'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text('Failed to load image'),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            // Adds spacing between the image and the text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${bookingData['serviceNameLower'] ?? 'No Service'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        " ${bookingData['bookingId']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.calendarAlt,
                                            // Change to desired icon
                                            size: 14,
                                            color: Colors.grey[700],
                                          ),
                                          SizedBox(width: 4),
                                          // Adds spacing between the icon and text
                                          Text(
                                            " ${bookingData['date']}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      // Adds spacing between date and time rows
                                      Row(
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.clock,
                                            // Change to desired icon
                                            size: 14,
                                            color: Colors.grey[700],
                                          ),
                                          SizedBox(width: 4),
                                          // Adds spacing between the icon and text
                                          Text(
                                            " ${bookingData['time']}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.heading),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Booking Status",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            bookingData['status'] == 'Pending'
                                                ? Colors.blue
                                                : Colors.green,
                                      ),
                                    ),
                                    Text(
                                      " ${bookingData['status']}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            bookingData['status'] == 'Pending'
                                                ? Colors.blue
                                                : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Payment Status ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: bookingData['paymentstatus'] ==
                                                'Pending'
                                            ? Colors.blue
                                            : Colors.green,
                                      ),
                                    ),
                                    Text(
                                      " ${bookingData['paymentstatus']}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: bookingData['paymentstatus'] ==
                                                'Pending'
                                            ? Colors.blue
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // trailing: Text(
                        //   "\$${bookingData['total'].toStringAsFixed(2)}",
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16,
                        //     color: Colors.green,
                        //   ),
                        // ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => bookingproviderdetail(
                                bookings: document,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            )),
        SizedBox(height: 15),
      ]);

  Widget servicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Services",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                  fontSize: 15,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceScreenWidget(
                        onBackPress: widget.onBackPress,
                      ),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('service')
                .where('providerId', isEqualTo: currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ));
              }
              if (!snapshot.hasData) {
                return Center(child: Text("No Data Available"));
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.docs.length < 4
                    ? snapshot.data!.docs.length
                    : 4,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  String category = doc['Category'] ?? 'No category';

                  // Determine the Lottie animation based on the category
                  String lottieAnimationPath;
                  switch (category) {
                    case 'Online Services':
                      lottieAnimationPath = 'assets/images/onlineservice.json';
                      break;
                    case 'Development':
                      lottieAnimationPath = 'assets/images/development.json';
                      break;
                    case 'Healthcare':
                      lottieAnimationPath = 'assets/images/healthcare.json';
                      break;
                    case 'Design & Multimedia':
                      lottieAnimationPath = 'assets/images/designmulti.json';
                      break;
                    case 'Telemedicine':
                      lottieAnimationPath = 'assets/images/Telemedicine.json';
                      break;
                    case 'Education':
                      lottieAnimationPath = 'assets/images/education.json';
                      break;
                    case 'Retail':
                      lottieAnimationPath = 'assets/images/Retail.json';
                      break;
                    case 'Online Consultation':
                      lottieAnimationPath =
                          'assets/images/Online Consultation.json';
                      break;
                    case 'Digital Marketing':
                      lottieAnimationPath =
                          'assets/images/Digital Marketing.json';
                      break;
                    case 'Online Training':
                      lottieAnimationPath =
                          'assets/images/Digital Marketing.json';
                      break;
                    case 'Event Management':
                      lottieAnimationPath =
                          'assets/images/Event Management.json';
                      break;
                    case 'Video Editing':
                      lottieAnimationPath = 'assets/images/Graphic Design.json';
                      break;
                    case 'Home & Maintenance ':
                      lottieAnimationPath =
                          'assets/images/Home & Maintenance.json';
                      break;
                    case 'Hospitality':
                      lottieAnimationPath = 'assets/images/Hospitality.json';
                      break;
                    case 'Social Media Management':
                      lottieAnimationPath =
                          'assets/images/Social Media Management.json';
                      break;
                    case 'IT Support':
                      lottieAnimationPath = 'assets/images/IT Support.json';
                      break;
                    case 'Personal & Lifestyle ':
                      lottieAnimationPath =
                          'assets/images/Personal & Lifestyle.json';
                      break;
                    case 'Graphic Design':
                      lottieAnimationPath = 'assets/images/Graphic Design.json';
                      break;
                    case 'Finance':
                      lottieAnimationPath = 'assets/images/Finance.json';
                      break;
                    default:
                      lottieAnimationPath = 'assets/images/default.json';
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ServiceDetailScreen(service: doc),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(color: Colors.blue), // Add this line
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue[100]!.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Lottie animation centered in the container
                            Positioned.fill(
                              child: Container(
                                color: Colors.blueGrey,
                                // Keep the overall container's color
                                child: Center(
                                  child: Container(
                                    height: 220, // Same as Lottie size
                                    width: 200, // Same as Lottie size
                                    decoration: BoxDecoration(
                                      color: Colors.indigoAccent,
                                      // Set the background of this smaller box to white
                                      borderRadius: BorderRadius.circular(
                                          15), // Add some rounding if needed
                                    ),
                                    child: Center(
                                      child: Lottie.asset(
                                        lottieAnimationPath,
                                        height: 130,
                                        width: 130,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: Colors.amber[700],
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                                  crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                                  children: [
                                    Text(
                                      doc['ServiceName'] ?? 'No name',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 13,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(-1.5, -1.5),
                                            color: Colors.black,
                                            blurRadius: 2,
                                          ),
                                          Shadow(
                                            offset: Offset(1.5, 1.5),
                                            color: Colors.black,
                                            blurRadius: 2,
                                          ),
                                          Shadow(
                                            offset: Offset(0, 0),
                                            color: Colors.black,
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center, // Center-align text
                                    ),
                                    SizedBox(height: 8), // Reduced space between text
                                    Text(
                                      "\u20A8 " + (doc['Price']?.toString() ?? 'No Price'),
                                      style: TextStyle(
                                        color: Colors.lightGreenAccent[400],
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center, // Center-align price
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

        ),
        SizedBox(height: 20,)
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double width;
  final FaIcon? icon;

  CustomButton(this.onPressed, this.text, this.height, this.width, {this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon ?? Container(), // Show icon if provided
      label: Text(text, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        backgroundColor: Colors.indigo, // Button background color
      ),
    );
  }
}
