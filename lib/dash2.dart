import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class AdminDashboardScreen1 extends StatefulWidget {
  const AdminDashboardScreen1({super.key});

  @override
  State<AdminDashboardScreen1> createState() => _AdminDashboardScreen1State();
}

class _AdminDashboardScreen1State extends State<AdminDashboardScreen1> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalServices() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('services').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching total services: $e');
      return 0;
    }
  }

  Future<int> getBookedServices() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('bookings')
          .where('status', whereIn: ['Accepted', 'In Progress', 'Complete']).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching booked services: $e');
      return 0;
    }
  }

  Future<int> getCashPayments() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('payments')
          .where('Method', isEqualTo: 'OnCash')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching cash payments: $e');
      return 0;
    }
  }

  Future<int> getCardPayments() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('card_payments') // Assuming you store card payments in a separate collection
          .where('payment_status', isEqualTo: 'Success') // Check for successful card payments
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching card payments: $e');
      return 0;
    }
  }

  Future<int> getPendingBookings() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('bookings')
          .where('status', isEqualTo: 'Pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching pending bookings: $e');
      return 0;
    }
  }

  Future<int> getCompletedBookings() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('bookings')
          .where('status', isEqualTo: 'Complete')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching completed bookings: $e');
      return 0;
    }
  }

  Future<int> getPositiveFeedback() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('reviews')
          .where('rating', isGreaterThanOrEqualTo: 4)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching positive feedback: $e');
      return 0;
    }
  }

  Future<int> getNegativeFeedback() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('reviews')
          .where('rating', isLessThan: 3)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching negative feedback: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildDashboardTile(
            title: 'Total Services',
            icon: Icons.home_repair_service,
            dataFetcher: getTotalServices,
            color: Colors.blue,
          ),
          _buildDashboardTile(
            title: 'Booked Services',
            icon: Icons.book_online,
            dataFetcher: getBookedServices,
            color: Colors.green,
          ),
          _buildDashboardTile(
            title: 'Cash Payments',
            icon: Icons.attach_money,
            dataFetcher: getCashPayments,
            color: Colors.orange,
          ),
          _buildDashboardTile(
            title: 'Card Payments',
            icon: Icons.credit_card,
            dataFetcher: getCardPayments,
            color: Colors.purple,
          ),
          _buildDashboardTile(
            title: 'Pending Bookings',
            icon: Icons.pending_actions,
            dataFetcher: getPendingBookings,
            color: Colors.amber,
          ),
          _buildDashboardTile(
            title: 'Completed Bookings',
            icon: Icons.check_circle,
            dataFetcher: getCompletedBookings,
            color: Colors.teal,
          ),
          _buildDashboardTile(
            title: 'Positive Feedback',
            icon: Icons.thumb_up,
            dataFetcher: getPositiveFeedback,
            color: Colors.lightGreen,
          ),
          _buildDashboardTile(
            title: 'Negative Feedback',
            icon: Icons.thumb_down,
            dataFetcher: getNegativeFeedback,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile({
    required String title,
    required IconData icon,
    required Future<int> Function() dataFetcher,
    required Color color,
  }) {
    return Card(
      elevation: 2.0,
      color: color.withOpacity(0.2), // Subtle background color
      child: InkWell(
        onTap: () {
          // Handle tile click (e.g., navigate to a detailed screen)
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48.0, color: color), // Colored icon
              const SizedBox(height: 16.0),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color), // Colored title
              ),
              const SizedBox(height: 8.0),
              FutureBuilder<int>(
                future: dataFetcher(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text('Error');
                  }
                  return Text(
                    snapshot.data.toString(),
                    style: TextStyle(fontSize: 24.0, color: color), // Colored count
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