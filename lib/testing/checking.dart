import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class FirestoreExample extends StatefulWidget {
  @override
  _FirestoreExampleState createState() => _FirestoreExampleState();
}

class _FirestoreExampleState extends State<FirestoreExample> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _couponIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCouponIds();
  }

  void fetchCouponIds() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('coupons').get();
      List<String> tempCouponIds = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('couponId')) {
          tempCouponIds.add(data['couponId']);
          print('Coupon ID: ${data['couponId']}'); // Debug print
        } else {
          print("couponId not found in the document ${doc.id}");
        }
      }
      setState(() {
        _couponIds = tempCouponIds;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching documents: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Coupon IDs'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _couponIds.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_couponIds[index]),
          );
        },
      ),
    );
  }
}
