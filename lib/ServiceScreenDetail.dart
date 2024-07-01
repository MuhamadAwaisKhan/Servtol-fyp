import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/edit%20service.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class ServiceDetailScreen extends StatefulWidget {
  final DocumentSnapshot service;

  ServiceDetailScreen({required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Future<void> _deletedata(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('service')
          .doc(documentId)
          .delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data Deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to Delete data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Service Details",style: TextStyle(fontFamily: 'Poppins',color: Colors.white),),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        backgroundColor: Colors.teal,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.service['ImageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.service['ImageUrl'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.image_not_supported, size: 200),
              SizedBox(height: 20),
              Column(
                children: [
                  uihelper.detailCard("Service Name",
                      widget.service['ServiceName'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Category", widget.service['Category'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Price", widget.service['Price'] ?? 'Not provided'),
                  uihelper.detailCard("Service Type",
                      widget.service['ServiceType'] ?? 'Not provided'),
                  uihelper.detailCard("Discount",
                      widget.service['Discount'] + "\%" ?? 'Not provided'),
                  uihelper.detailCard(
                      "Subcategory", widget.service['Subcategory'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Wage Type", widget.service['WageType'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Time Slot", widget.service['TimeSlot'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Province", widget.service['Province'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "City", widget.service['City'] ?? 'Not provided'),
                  uihelper.detailCard(
                      "Area", widget.service['Area'] ?? 'Not provided'),
                  uihelper.detailCard(
                    "Description", widget.service['Description'] ?? 'Not provided',
                    lastItem: true,),
                ],
              ),
      
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  uihelper.actionButton(
                      'Delete', Colors.red, Icons.dangerous_outlined,() => _deletedata(widget.service.id)),
                  uihelper.actionButton('Edit', Colors.blue,Icons.edit, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => editservice(
                          serviceId: widget.service.id,
                          sericename: widget.service["ServiceName"],
                          category: widget.service["Category"],
                          Subcategory: widget.service["Subcategory"],
                          Province: widget.service["Province"],
                          City: widget.service["City"],
                          Area: widget.service["Area"],
                          ServiceType: widget.service["ServiceType"],
                          WageType: widget.service["WageType"],
                          Price: widget.service["Price"],
                          Discount: widget.service["Discount"],
                          TimeSlot: widget.service["TimeSlot"],
                          Description: widget.service["Description"],
                        ),
                      ),
                    );
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
