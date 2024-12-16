import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:servtol/adminbooking.dart';
import 'package:servtol/adminreviews.dart';
import 'package:servtol/adminservices.dart';
import 'package:servtol/allservicescustomers.dart';
import 'package:servtol/paymentradmin.dart';
import 'package:servtol/reports.dart';
import 'package:servtol/util/AppColors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalServices() async {
    try {
      final snapshot = await _firestore.collection('service').get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching total services: $e');
      return 0;
    }
  }

  Future<int> getBookedServices() async {
    try {
      final snapshot = await _firestore.collection('bookings').get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching booked services: $e');
      return 0;
    }
  }

  Future<int> getCashPayments() async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('Method', isEqualTo: 'OnCash')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching cash payments: $e');
      return 0;
    }
  }

  Future<int> getCardPayments() async {
    try {
      final snapshot = await _firestore
          .collection('card_payments')
          .where('payment_status', isEqualTo: 'Success')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching card payments: $e');
      return 0;
    }
  }

  Future<int> getPendingBookings() async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'Pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching pending bookings: $e');
      return 0;
    }
  }

  Future<int> getCompletedBookings() async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'Complete')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching completed bookings: $e');
      return 0;
    }
  }

  Future<int> getPositiveFeedback() async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('emojiRating', isGreaterThanOrEqualTo: 3)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching positive feedback: $e');
      return 0;
    }
  }

  Future<int> getNegativeFeedback() async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('emojiRating', isGreaterThanOrEqualTo: 2)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching negative feedback: $e');
      return 0;
    }
  }

  // Widget _buildSummaryChart(String title, List<Future<int>> dataFetchers,
  //     List<String> labels, List<Color> colors) {
  //   return Container(
  //     height: 200,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 6,
  //           offset: const Offset(2, 4),
  //         ),
  //       ],
  //     ),
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 8),
  //         Expanded(
  //           child: FutureBuilder<List<int>>(
  //             future: Future.wait(dataFetchers),
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return const Center(
  //                   child: CircularProgressIndicator(),
  //                 );
  //               }
  //               if (snapshot.hasError) {
  //                 return const Center(
  //                   child: Text('Error loading chart data'),
  //                 );
  //               }
  //
  //               final data =
  //                   snapshot.data ?? List.filled(dataFetchers.length, 0);
  //
  //               return PieChart(
  //                 PieChartData(
  //                   sections: List.generate(data.length, (index) {
  //                     return PieChartSectionData(
  //                       value: data[index].toDouble(),
  //                       color: colors[index],
  //                       title: '${data[index]} ${labels[index]}',
  //                       radius: 50,
  //                       titleStyle: GoogleFonts.poppins(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     );
  //                   }),
  //                   sectionsSpace: 2,
  //                   centerSpaceRadius: 40,
  //                   borderData: FlBorderData(show: false),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Future<int> getTotalReports() async {
    try {
      final snapshot = await _firestore.collection('problem_reports').get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching total reports: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Admin Dashboard',
        style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProminentTile(
              title: 'Total Services',
              dataFetcher: getTotalServices,
              icon: FontAwesomeIcons.wrench,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => AdminServicesScreen(), // Pass the DocumentSnapshot here
                ),);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildDashboardTile(
                    title: 'Booked Services',
                    dataFetcher: getBookedServices,
                    icon: FontAwesomeIcons.bookOpen,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                          context,
                      MaterialPageRoute(
                        builder: (context) => adminbooking(bookingStatus: 'All',),
                      ) );
                    },
                  ),
                  _buildDashboardTile(
                    title: 'Pending Bookings',
                    dataFetcher: getPendingBookings,
                    icon: FontAwesomeIcons.clock,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => adminbooking(bookingStatus: 'Pending',),
                          ) );
                    },
                  ),
                  _buildDashboardTile(
                    title: 'Completed Bookings',
                    dataFetcher: getCompletedBookings,
                    icon: FontAwesomeIcons.circleCheck,
                    color: Colors.lightBlue,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => adminbooking(bookingStatus: 'Complete',),
                          ) );
                    },
                  ),

                  _buildDashboardTile(
                    title: 'Positive Feedback',
                    dataFetcher: getPositiveFeedback,
                    icon: FontAwesomeIcons.thumbsUp,
                    color: Colors.teal,
                    onTap: () async {
                      try {
                        final reviewsSnapshot = await _firestore
                            .collection('reviews')
                            .where('emojiRating', isGreaterThanOrEqualTo: 3)
                            .get();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => adminfeedback(
                              reviews: reviewsSnapshot.docs,
                              title: 'Positive Feedback', // Pass the title
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint('Error fetching reviews: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error loading reviews. Please try again.')),
                        );
                      }
                    },
                  ),

                _buildDashboardTile(
                  title: 'Negative Feedback',
                  dataFetcher: getNegativeFeedback,
                  icon: FontAwesomeIcons.thumbsUp,
                  color: Colors.red,
                  onTap: () async {
                    try {
                      final reviewsSnapshot = await _firestore
                          .collection('reviews')
                          .where('emojiRating', isLessThanOrEqualTo: 2) // Correct condition
                          .get();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => adminfeedback(
                            reviews: reviewsSnapshot.docs,
                            title: 'Negative Feedback', // Pass the title
                          ),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error fetching reviews: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error loading reviews. Please try again.')),
                      );
                    }
                  },
                ),

                  _buildDashboardTile(
                    title: 'Cash Payments',
                    dataFetcher: getCashPayments,
                    icon: FontAwesomeIcons.moneyBillWave,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => paymentadmin(
                            paymentMethod: 'OnCash',
                            title:'Cash Payment'// Pass the payment method
                          ),
                        ),
                      );
                      },
                  ),
                  _buildDashboardTile(
                    title: 'Card Payments',
                    dataFetcher: getCardPayments,
                    icon: FontAwesomeIcons.creditCard,
                    color: Colors.deepOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => paymentadmin(
                            paymentMethod: 'Paid by Card',
                            title: 'Card Payments',// Pass the payment method
                          ),
                        ),
                      );


                    },
                  ),
                  _buildDashboardTile(
                    title: 'Reports Insight',
                    dataFetcher: getTotalReports, // Fetches the total number of reports
                    icon: FontAwesomeIcons.exclamationCircle,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminReportScreen(),
                        ),
                      );
                    },
                  ),

                ],
              ),

            ),
            // Inside the GridView.count in AdminDashboardScreen
            SizedBox(height: 15),



          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile({
    required String title,
    required Future<int> Function() dataFetcher,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FutureBuilder<int>(
                future: dataFetcher(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      color: Colors.white,
                    );
                  }
                  if (snapshot.hasError) {
                    return const Text(
                      'Error',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  return Text(
                    '${snapshot.data}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildProminentTile({
  required String title,
  required Future<int> Function() dataFetcher,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.white,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<int>(
                  future: dataFetcher(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    }
                    if (snapshot.hasError) {
                      return const Text(
                        'Error',
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    return Text(
                      '${snapshot.data}',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class DetailScreen extends StatelessWidget {
  final String title;

  const DetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Details for $title',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
