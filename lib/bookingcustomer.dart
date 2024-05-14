import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
class bookingcustomer extends StatefulWidget {
  const bookingcustomer({super.key});

  @override
  State<bookingcustomer> createState() => _bookingcustomerState();
}

class _bookingcustomerState extends State<bookingcustomer> {
  final List<Map<String, dynamic>> booking = [
    {
      'Status': 'On Going',
      'BookingId': '#260',
      'BookingName': 'Filter Replacement',
      'Price': '\$40.00',
      'Address': '1345 SWL PAK',
      'Date': 'Nov 16 2024 At 11:32 AM',
      'Customer': 'Pedro Norris',
      'Service Provider': 'Don Akon',
    },
    {
      'Status': 'Accepted',
      'BookingId': '#250',
      'BookingName': 'App Development',
      'Price': '\$400.00',
      'Address': '1345 SWL PAK',
      'Date': 'Nov 16 2024 At 11:32 AM',
      'Customer': 'Seveston',
      'Service Provider': 'Don Akon',
    },
    {
      'Status': 'Waiting',
      'BookingId': '#210',
      'BookingName': 'Children Counselling ',
      'Price': '\$40.00',
      'Address': '1345 SWL PAK',
      'Date': 'Nov 16 2024 At 11:32 AM',
      'Customer': 'John Wisha',
      'Service Provider': 'Don Akon',
    },
    {
      'Status': 'Completed',
      'BookingId': '#260',
      'BookingName': 'System Replacement',
      'Price': '\$40.00',
      'Address': '1345 SWL PAK',
      'Date': 'Nov 16 2024 At 11:32 AM',
      'Customer': 'Pedro Norris',
      'Service Provider': 'Don Akon',
    },
    {
      'Status': 'Pending Approval',
      'BookingId': '#2160',
      'BookingName': 'CustomSystem',
      'Price': '\$490.00',
      'Address': '1345 SWL PAK',
      'Date': 'Nov 16 2024 At 11:32 AM',
      'Customer': 'Pedro Norris',
      'Service Provider': 'Don Akon',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Bookings",
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
        itemCount: booking.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.teal,
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                booking[index]['BookingName'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${booking[index]['Status']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'BookingId: ${booking[index]['BookingId']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Price: ${booking[index]['Price']}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Address: ${booking[index]['Address']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Date: ${booking[index]['Date']}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Customer: ${booking[index]['Customer']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Service Provider: ${booking[index]['Service Provider']}',
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
