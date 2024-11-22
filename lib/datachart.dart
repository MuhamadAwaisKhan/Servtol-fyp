import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servtol/util/AppColors.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Future<int> getPendingBookings(FirebaseFirestore firestore) async {
    final snapshot = await firestore
        .collection('bookings')
        .where('status', isEqualTo: 'Pending')
        .get();
    return snapshot.docs.length;
  }

  Future<int> getCompletedBookings(FirebaseFirestore firestore) async {
    final snapshot = await firestore
        .collection('bookings')
        .where('status', isEqualTo: 'Complete')
        .get();
    return snapshot.docs.length;
  }

  Future<int> getCardPayments(FirebaseFirestore firestore) async {
    final snapshot = await firestore
        .collection('card_payments')
        .where('payment_status', isEqualTo: 'Success')
        .get();
    return snapshot.docs.length;
  }

  Future<int> getCashPayments(FirebaseFirestore firestore) async {
    final snapshot = await firestore
        .collection('payments')
        .where('Method', isEqualTo: 'OnCash')
        .get();
    return snapshot.docs.length;
  }
  Future<int> getPositiveFeedback(FirebaseFirestore firestore) async {
    try {
      final snapshot = await firestore
          .collection('reviews')
          .where('emojiRating', isGreaterThanOrEqualTo: 3)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching positive feedback: $e');
      return 0;
    }
  }

  Future<int> getNegativeFeedback(FirebaseFirestore firestore) async {
    try {
      final snapshot = await firestore
          .collection('reviews')
          .where('emojiRating', isLessThan: 2)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching negative feedback: $e');
      return 0;
    }
  }
  Future<int> getTotalServices(FirebaseFirestore firestore) async {
    try {
      final snapshot = await firestore.collection('service').get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching total services: $e');
      return 0;
    }
  }

  Future<int> getBookedServices(FirebaseFirestore firestore) async {
    try {
      final snapshot = await firestore.collection('bookings').get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching booked services: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts',
          style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: Colors.white),

        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildPieChart(
              title: 'Bookings Overview',
              futureData: Future.wait([
                getCompletedBookings(firestore),
                getPendingBookings(firestore),
              ]),
              colors: [Colors.green, Colors.orange],
              labels: ['Completed Bookings', 'Pending Bookings'],
              legendLabels: [
                {'label': 'Completed', 'color': Colors.green},
                {'label': 'Pending', 'color': Colors.orange},
              ],
            ),
            const SizedBox(height: 32),
            _buildPieChart(
              title: 'Payment Methods',
              futureData: Future.wait([
                getCardPayments(firestore),
                getCashPayments(firestore),
              ]),
              colors: [Colors.teal, Colors.purple],
              labels: ['Card Payment', 'Cash Payment'],
              legendLabels: [
                {'label': 'Card', 'color': Colors.teal},
                {'label': 'Cash', 'color': Colors.purple},
              ],
            ),
            const SizedBox(height: 32),
            _buildPieChart(
              title: 'Feedback',
              futureData: Future.wait([
                getPositiveFeedback(firestore),
                getNegativeFeedback(firestore),
              ]),
              colors: [Colors.lightBlue, Colors.red],
              labels: ['Positive Feedback ', 'Negative Feedback'],
              legendLabels: [
                {'label': 'Positive', 'color': Colors.lightBlue},
                {'label': 'Negative', 'color': Colors.red},
              ],
            ),
             SizedBox(height: 32),
        _buildPieChart(
          title: 'Services',
          futureData: Future.wait([
            getTotalServices(firestore),
            getBookedServices(firestore),
          ]),
          colors: [Colors.indigoAccent, Colors.deepOrangeAccent],
          labels: ['Total Services', 'Booked Services'],
          legendLabels: [
            {'label': 'Total', 'color': Colors.indigoAccent},
            {'label': 'Booked', 'color': Colors.deepOrangeAccent},
          ],
        )

          ],
        ),
      ),
    );
  }

  Widget _buildPieChart({
    required String title,
    required Future<List<int>> futureData,
    required List<Color> colors,
    required List<String> labels,
    required List<Map<String, dynamic>> legendLabels, // Legend data for colors and labels
  }) {
    return Container(
      height: 300, // Adjusted height for including the legend
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<int>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading chart data'));
          }

          final data = snapshot.data ?? [0, 0];
          final total = data.reduce((a, b) => a + b);
          final hasData = total > 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sections: List.generate(
                            data.length,
                                (index) => PieChartSectionData(
                              value: hasData ? data[index].toDouble() : 1,
                              color: colors[index],
                              title: hasData ? '${data[index]}' : '',
                              radius: 50,
                              titleStyle: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: legendLabels
                            .map(
                              (legend) => Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: legend['color'],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                legend['label'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


}
