import 'package:flutter/material.dart';
class PaymentScreenWidget extends StatefulWidget {
  const PaymentScreenWidget({super.key});

  @override
  State<PaymentScreenWidget> createState() => _PaymentScreenWidgetState();
}

class _PaymentScreenWidgetState extends State<PaymentScreenWidget> {
  @override

  Widget build(BuildContext context) {
    return Container(
      child: Text('Payment Screen'),
    );
  }
}