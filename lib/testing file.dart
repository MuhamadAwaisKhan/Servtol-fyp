import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:servtol/notifications/NotificationService.dart';

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
     notificationService.requestnotificationpermission();
  }


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


