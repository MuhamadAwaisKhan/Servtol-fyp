import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/util/AppColors.dart';

class PaymentScreenWidget extends StatefulWidget {
  final Function onBackPress;

  PaymentScreenWidget({Key? key, required this.onBackPress}) : super(key: key);

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
      'amount': '\$128.00'
    },
    {
      'name': 'Tracy Jones',
      'paymentId': '#200',
      'status': 'Paid',
      'method': 'Stripe',
      'amount': '\$28.00'
    },
    {
      'name': 'Awais Jones',
      'paymentId': '#219',
      'status': 'Paid',
      'method': 'Cash',
      'amount': '\$38.00'
    },
    {
      'name': 'Wisha Noor ',
      'paymentId': '#002',
      'status': 'Pending',
      'method': 'Cash',
      'amount': '\$68.00'
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/images/payments.json', height: 200),

          Expanded(
            child: ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.teal,
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
          ),
        ],
      ),
    );
  }
}
