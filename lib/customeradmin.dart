import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/util/AppColors.dart';

class CustomerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers',
          style: TextStyle(color:AppColors.heading,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),

        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('customer').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final customers = snapshot.data!.docs;
          if (customers.isEmpty) {
            return Center(
              child: Text(
                'No Customers Found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              var customer = customers[index];
              return Card(
                color: Colors.lightBlueAccent,

                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(customer['ProfilePic']),
                    onBackgroundImageError: (_, __) =>
                        AssetImage('assets/images/fallback_image.png'),
                  ),
                  title: Text(
                    customer['FirstName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    customer['Email'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Icon(FontAwesomeIcons.chevronRight,color: Colors.white, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomerDetailsScreen(customer: customer),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}



class CustomerDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot customer;
  CustomerDetailsScreen({required this.customer});

  @override
  Widget build(BuildContext context) {
    final data = customer.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Details',
          style: TextStyle(
            color: AppColors.heading,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: AppColors.heading),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(data['ProfilePic'] ?? ''),
                onBackgroundImageError: (_, __) =>
                    AssetImage('assets/images/fallback_image.png'),
              ),
            ),
             SizedBox(height: 24),
            detailItem(FontAwesomeIcons.user, 'First Name', data['FirstName']),
            detailItem(FontAwesomeIcons.user, 'Last Name', data['LastName']),
            detailItem(FontAwesomeIcons.userTag, 'Username', data['Username']),
            detailItem(FontAwesomeIcons.envelope, 'Email', data['Email']),
            detailItem(FontAwesomeIcons.phone, 'Mobile', data['Mobile']),
            // Spacer(),
            SizedBox(height: 20,),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('customer')
                      .doc(customer.id)
                      .delete();
                  Navigator.pop(context);
                },
                icon: Icon(FontAwesomeIcons.trashAlt, size: 16),
                label: Text('Delete Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function to render detail rows with icons and consistent design
  Widget detailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.heading,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: value ?? 'N/A',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
