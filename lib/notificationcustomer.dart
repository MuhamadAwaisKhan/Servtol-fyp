import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
class customernotification extends StatefulWidget {
  const customernotification({super.key});

  @override
  State<customernotification> createState() => _customernotificationState();
}

class _customernotificationState extends State<customernotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificatons',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 19,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 17, // Replace with the actual number of messages
              itemBuilder: (context, index) {
                // Replace this with your message widget
                return Center(
                  child: ListTile(
                    title: Center(child: Text('Notification $index',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                        color: AppColors.black,
                      ),
                    ),
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
