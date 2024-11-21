import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // Example Data
    final int totalServices = 120;
    final int bookedServices = 75;
    final int pendingBookings = 20;
    final int completedBookings = 55;
    final int feedbackPositive = 45;
    final int feedbackNegative = 15;
    final int paymentsByCard = 50;
    final int paymentsByCash = 25;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // Dashboard Tile Widgets
            _buildDashboardTile(
              title: 'Total Services',
              count: totalServices,
              icon: Icons.apps,
              color: Colors.purple,
            ),
            _buildDashboardTile(
              title: 'Booked Services',
              count: bookedServices,
              icon: Icons.book_online,
              color: Colors.green,
            ),
            _buildDashboardTile(
              title: 'Pending Bookings',
              count: pendingBookings,
              icon: Icons.pending,
              color: Colors.orange,
            ),
            _buildDashboardTile(
              title: 'Completed Bookings',
              count: completedBookings,
              icon: Icons.done_all,
              color: Colors.blue,
            ),
            _buildDashboardTile(
              title: 'Positive Feedback',
              count: feedbackPositive,
              icon: Icons.thumb_up,
              color: Colors.lightGreen,
            ),
            _buildDashboardTile(
              title: 'Negative Feedback',
              count: feedbackNegative,
              icon: Icons.thumb_down,
              color: Colors.red,
            ),
            _buildDashboardTile(
              title: 'Payments by Card',
              count: paymentsByCard,
              icon: Icons.credit_card,
              color: Colors.teal,
            ),
            _buildDashboardTile(
              title: 'Payments by Cash',
              count: paymentsByCash,
              icon: Icons.money,
              color: Colors.brown,
            ),
          ],
        ),
      ),
    );
  }

  // Helper to Build Dashboard Tile
  Widget _buildDashboardTile({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
