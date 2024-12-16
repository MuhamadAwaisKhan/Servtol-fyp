import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:servtol/util/AppColors.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Problem Reports",
          style: TextStyle(fontFamily: 'Poppins',color: AppColors.heading, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "All Reports"),
            Tab(text: "Resolved"),
          ],
          labelStyle: const TextStyle(fontFamily: 'Poppins'),
          indicatorColor: Colors.white,
        ),
      ),
      backgroundColor: AppColors.background,

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList(), // Fetch all reports
          _buildReportsList(showResolved: true), // Fetch only resolved reports
        ],
      ),
    );
  }

  Widget _buildReportsList({bool? showResolved}) {
    Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('problem_reports')
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Filter for resolved if specified
    if (showResolved != null) {
      stream = FirebaseFirestore.instance
          .collection('problem_reports')
          .where('resolved', isEqualTo: showResolved)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              showResolved == true
                  ? "No resolved reports."
                  : "No reports found.",
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
            ),
          );
        }

        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final data = report.data() as Map<String, dynamic>;
            final description = data['description'] ?? "No description provided";
            final category = data['category'] ?? "Unknown category";
            final userType = data['userType'] ?? "Unknown user";
            final resolved = data['resolved'] ?? false;
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            final formattedDate = timestamp != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)
                : "No timestamp";

            return Card(
              color: Colors.lightBlueAccent ,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        resolved
                            ? const FaIcon(FontAwesomeIcons.checkCircle,
                            color: Colors.green, size: 18)
                            : const FaIcon(FontAwesomeIcons.timesCircle,
                            color: Colors.red, size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "User Type: $userType",
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (!resolved) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _markAsResolved(report.id),
                          icon: const FaIcon(FontAwesomeIcons.check,
                              color: Colors.white, size: 16),
                          label: const Text(
                            "Mark as Resolved",
                            style: TextStyle(fontFamily: 'Poppins', color: Colors.white, ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Service Issue":
        return FontAwesomeIcons.cogs;
      case "Payment Problem":
        return FontAwesomeIcons.creditCard;
      case "App Bug":
        return FontAwesomeIcons.bug;
      default:
        return FontAwesomeIcons.questionCircle;
    }
  }

  Future<void> _markAsResolved(String reportId) async {
    try {
      await FirebaseFirestore.instance
          .collection('problem_reports')
          .doc(reportId)
          .update({'resolved': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report marked as resolved.")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update the report.")),
      );
    }
  }
}
