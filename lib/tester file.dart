import 'package:flutter/material.dart';

import 'notifications/notificationmessageservice.dart';

class tester extends StatefulWidget {
  const tester({super.key});

  @override
  State<tester> createState() => _testerState();
}

class _testerState extends State<tester> {


  NotificationService notificationService =NotificationService();
  @override
  void initState(){
    // TODO: implement ==initState
    super.initState();
    notificationService.requestNotificationPermission();
    // notificationService.Istokenrefresed();
    // notificationService.firebaseInit();
    // notificationService.getDeviceToken().then((value){
  // print("Device token");
  // print(value);
  //
  //   });
  }

//   Column(
//   crossAxisAlignment: CrossAxisAlignment.center,
//   children: [
//   Lottie.asset('assets/images/bookingc.json', height: 200),
//   Expanded(
//   child: StreamBuilder<QuerySnapshot>(
//   stream: _firestore.collection('bookings')
//       .where('customerId', isEqualTo: customerId)
//       .snapshots(), // Fixed here
//   builder: (context, snapshot) {
//   if (snapshot.hasError) {
//   return Text('Error: ${snapshot.error}');
//   }
//   if (snapshot.connectionState == ConnectionState.waiting) {
//   return Center(child: CircularProgressIndicator());
//   }
//   return ListView(
//   children: snapshot.data!.docs.map((DocumentSnapshot document) {
//   return FutureBuilder<Map<String, dynamic>>(
//   future: fetchBookingDetails(document.data() as Map<String, dynamic>),
//   builder: (context, detailSnapshot) {
//   if (detailSnapshot.connectionState == ConnectionState.waiting) {
//   return Center(child: CircularProgressIndicator());
//   }
//   if (detailSnapshot.hasError || detailSnapshot.data == null) {
//   return Text('Error: Failed to fetch booking details');
//   }
//   return bookingCard(detailSnapshot.data!, document);
//   },
//   );
//   }).toList(),
//   );
//   },
//   ),
//   ),
//   ],
//   ),
//   );
// }


@override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(
        title: Text('Notification Example'),
      ),
      body: Center(
        child: Container(
            width: 300, // Adjust width as needed
            height: 200, // Adjust height as needed
            child:Text('My Name is khan')
        ),
      ),
    );
  }
}


