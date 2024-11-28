import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:servtol/util/AppColors.dart';

class WalletHistoryScreen extends StatefulWidget {
  @override
  _WalletHistoryScreenState createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  String selectedTransactionType = "All";
  String selectedStatus = "All";

  final List<Map<String, dynamic>> transactions = [
    {
      "date": "2024-11-20",
      "description": "Service Payment",
      "amount": 150.00,
      "isCredit": true,
      "status": "Completed"
    },
    {
      "date": "2024-11-18",
      "description": "Withdrawal",
      "amount": -50.00,
      "isCredit": false,
      "status": "Pending"
    },
    {
      "date": "2024-11-15",
      "description": "Service Payment",
      "amount": 200.00,
      "isCredit": true,
      "status": "Completed"
    },
  ];

  List<Map<String, dynamic>> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    filteredTransactions = List.from(transactions);
  }

  void _applyFilters() {
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        final matchesType = selectedTransactionType == "All" ||
            (selectedTransactionType == "Credit" && transaction['isCredit']) ||
            (selectedTransactionType == "Debit" && !transaction['isCredit']);

        final matchesStatus = selectedStatus == "All" ||
            selectedStatus == transaction['status'];

        return matchesType && matchesStatus;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedTransactionType = "All";
      selectedStatus = "All";
      filteredTransactions = List.from(transactions);
    });
  }

  void _openFilterDialog() {
    String tempTransactionType = selectedTransactionType;
    String tempStatus = selectedStatus;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Filter Transactions",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tempTransactionType,
                decoration: const InputDecoration(labelText: "Transaction Type"),
                items: ["All", "Credit", "Debit"]
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  tempTransactionType = value!;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tempStatus,
                decoration: const InputDecoration(labelText: "Status"),
                items: ["All", "Completed", "Pending"]
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  tempStatus = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearFilters();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Change the text color of the button
              ),
              child: const Text("Clear"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedTransactionType = tempTransactionType;
                  selectedStatus = tempStatus;
                  _applyFilters();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.indigo, // Text color of the button
              ),
              child: const Text("Apply"),
            ),
          ],

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0f4c75), Color(0xFF3282b8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Wallet History",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.filter, color: Colors.white),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Wallet Balance Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0f4c75), Color(0xFF3282b8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Balance",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "\u20A8500.00",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle withdraw funds
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Withdraw Funds",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF0f4c75),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Transactions Header
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transaction History",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ?  Center(
              child: Text("No transactions found."),
            )
                : ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction['isCredit']
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: FaIcon(
                        transaction['isCredit']
                            ? FontAwesomeIcons.arrowUp
                            : FontAwesomeIcons.arrowDown,
                        color: transaction['isCredit']
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(
                      transaction['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      transaction['date'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\u20A8${transaction['amount'].toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            color: transaction['isCredit']
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          transaction['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: transaction['status'] == "Completed"
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
