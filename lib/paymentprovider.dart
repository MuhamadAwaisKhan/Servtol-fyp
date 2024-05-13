import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';

class PaymentScreenWidget extends StatefulWidget {
  final Function backPress;

  PaymentScreenWidget({Key? key, required this.backPress}) : super(key: key);

  @override
  State<PaymentScreenWidget> createState() => _PaymentScreenWidgetState();
}

class _PaymentScreenWidgetState extends State<PaymentScreenWidget> {
  final List<Map<String, dynamic>> payments = [
    {
      'name': 'Pedro Norris',
      'paymentId': '#230',
      'status': 'Paid',
      'method': 'Wallet',
      'amount': '\$40.00'
    },
    {
      'name': 'Pedro Norris',
      'paymentId': '#221',
      'status': 'Paid',
      'method': 'Stripe',
      'amount': '\$38.00'
    },
    {
      'name': 'Tracy Jones',
      'paymentId': '#209',
      'status': 'Paid',
      'method': 'Stripe',
      'amount': '\$38.00'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Payment",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey[900],
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                payments[index]['name'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment ID: ${payments[index]['paymentId']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Status: ${payments[index]['status']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Method: ${payments[index]['method']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Amount: ${payments[index]['amount']}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
