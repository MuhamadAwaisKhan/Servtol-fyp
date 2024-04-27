import 'package:flutter/material.dart';
class chatcustomer extends StatefulWidget {
  const chatcustomer({super.key});

  @override
  State<chatcustomer> createState() => _chatcustomerState();
}

class _chatcustomerState extends State<chatcustomer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Chat Customer Screen'),
    );
  }
}