import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
class notificationprovider extends StatefulWidget {
  const notificationprovider({super.key});

  @override
  State<notificationprovider> createState() => _notificationproviderState();
}

class _notificationproviderState extends State<notificationprovider> {
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
