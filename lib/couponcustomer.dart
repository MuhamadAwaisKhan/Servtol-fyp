import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyCouponScreen extends StatefulWidget {
  final double originalTotal;

  ApplyCouponScreen({required this.originalTotal});

  @override
  _ApplyCouponScreenState createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  final TextEditingController _couponController = TextEditingController();
  String _message = '';
  double _discountedTotal = 0;

  Future<void> applyCoupon() async {
    var coupons = await FirebaseFirestore.instance
        .collection('coupons')
        .where('name', isEqualTo: _couponController.text)
        .get();

    if (coupons.docs.isNotEmpty) {
      double discount = double.parse(coupons.docs.first['discount']);
      setState(() {
        _discountedTotal = widget.originalTotal - (widget.originalTotal * discount / 100);
        _message = 'Coupon applied! Discount: $discount%';
      });
    } else {
      setState(() {
        _message = 'Invalid coupon!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Apply Coupon"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _couponController,
              decoration: InputDecoration(
                labelText: 'Enter Coupon Code',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: applyCoupon,
            child: Text('Apply Coupon'),
          ),
          Text(_message),
          if (_discountedTotal > 0)
            Text('Original Total: \$${widget.originalTotal.toStringAsFixed(2)}\nDiscounted Total: \$${_discountedTotal.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
