import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servtol/util/AppColors.dart';

class ApplyCouponScreen extends StatefulWidget {
  final double originalTotal;

  ApplyCouponScreen({required this.originalTotal});

  @override
  _ApplyCouponScreenState createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  List<DocumentSnapshot> coupons = [];
  String _message = '';
  double _discountedTotal = 0;

  @override
  void initState() {
    super.initState();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('coupons').get();
      setState(() {
        coupons = snapshot.docs;
      });
    } catch (e) {
      setState(() {
        _message = "Error fetching coupons: $e";
      });
      print("Failed to fetch coupons: $e");
    }
  }


  void applyCoupon(double discount, String couponId) {
    double newTotal = widget.originalTotal - (widget.originalTotal * discount / 100);
    setState(() {
      _discountedTotal = newTotal;
      _message = 'Coupon applied! Discount: $discount%';
    });
    // Correctly returning the new total and the coupon ID
    Navigator.pop(context, {'discountedTotal': newTotal, 'couponId': couponId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Apply Coupon",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: coupons.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                var coupon = coupons[index];
                double discount = double.parse(coupon['discount'].toString());
                return Card(
                  color: Colors.deepPurple[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '\$$discount DISCOUNT',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          coupon['code'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Use this code to get \$$discount off',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Expiry Date : ${coupon['expiryDate']}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          child: Text('Apply'),
                          onPressed: () =>  applyCoupon(discount, coupon.id),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: _discountedTotal > 0
          ? Text(
              'Original Total: \$${widget.originalTotal.toStringAsFixed(2)}\nDiscounted Total: \$${_discountedTotal.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            )
          : SizedBox(),
    );
  }
}
