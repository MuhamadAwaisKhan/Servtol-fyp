import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:fl_chart/fl_chart.dart';

class providermainlayout extends StatefulWidget {
  const providermainlayout({super.key});

  @override
  State<providermainlayout> createState() => _providermainlayoutState();
}

class _providermainlayoutState extends State<providermainlayout> {
  int myindex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Provider Home",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.message_outlined),

            onPressed: () {
              // Add your search functionality here
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),

            onPressed: () {
              // Add your notifications functionality here
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
        
            children: [
        Column(
        children: [
        Padding(
        padding: const EdgeInsets.only(right: 195.0),
        child: Text(
          "Hello, Awais Khan",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            // fontSize: 17,
            color: AppColors.heading,
          ),
        ),
            ),
            SizedBox(height: 15,),
            Padding(
            padding: const EdgeInsets.only(right: 215.0),
            child: Text(
            "Welcome back!",
            style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.grey,
            ),
            ),
            ),
            ],
            ),
        
            SizedBox(height: 5),
            Container(
            child: Row(
        
        
            children: [
            Padding(
            padding: const EdgeInsets.only(right: 8.0,
            left: 18.0),
            child: Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.black,
            ),
            ),
            SizedBox(width: 8),
            Padding(
            padding: const EdgeInsets.only(right: 58.0),
            child: Text(
            "Today's Earning",
            style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
            ),
            ),
            ),
            Text(
            "\$0.00",
            style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.grey,
            ),
            ),
            ],
            ),
            ),
            SizedBox(height: 15,),
            Column(
            children: [
        
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            uihelper.CustomButton(() { }, "Booking"),
            uihelper.CustomButton(() { }, "Total Service")
            ],
            ),
            SizedBox(height: 15,),
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            uihelper.CustomButton(() { }, "Monthly Earning"),
            uihelper.CustomButton(() { }, " Wallet History")
            ],
            ),
        
        
            ],
        
            ),
            SizedBox(height:20 ,),
            Text("Monthly Revenue", style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
            ),),
            SizedBox(
            height: 15,
            ),
            Center(
            child: Container(
        
            width: 350, // Adjust width as needed
            height: 200, // Adjust height as needed
            child: LineChart(
            LineChartData(
            gridData: FlGridData(
            show: true,
            ),
            titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true),
            bottomTitles: SideTitles(showTitles: true),
            ),
            borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
            ),
            lineBarsData: [
            LineChartBarData(
            spots: [
            FlSpot(0, 3),
            FlSpot(1, 4),
            FlSpot(2, 2),
            FlSpot(3, 5),
            FlSpot(4, 1),
            ],
            isCurved: true,
            colors: [Colors.blue],
            barWidth: 2,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            ),
            ],
            ),
            ),
            ),
            ),
            SizedBox(height:20 ,),
            Text("Upcoming Booking", style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
            ),),
            SizedBox(height: 15,),
            Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
            child: Column(
            children: [
            Card(child: Text("Booking 1")),
            Card(child: Text("Booking 2")),
            Card(child: Text("Booking 3")),
            ]),
            ),
        
            SizedBox(height: 15,),
            Container(
              width: 310,
              height: 100,
            decoration: BoxDecoration(
            border: Border.all(
            color: Colors.black,
            width: 1,
            ),
            ),
            child: Column(
            children: [
            Text(" My Services", style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.heading,)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Text("Services1"),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Text("Services2"),
            ),
        
        
          ],),
          SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Text("Services3"),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Text("Services4"),
            ),
          ],)
            ],
            ),
            ),
        SizedBox(height: 15,),
              BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                // showSelectedLabels: ,
                  backgroundColor: Colors.indigo,
                 // showUnselectedLabels:false ,
                onTap: (index){
                 setState(() {
                   myindex=index;
                 });
                },
                  currentIndex: myindex,
                  items: [

                BottomNavigationBarItem(icon: Icon(Icons.home_filled),
                label: "Home",
                backgroundColor: Colors.green,
                ),
                BottomNavigationBarItem(icon: Icon(Icons.bolt_outlined),
                    label: "Booking",
                backgroundColor: Colors.cyan,
                ),
                BottomNavigationBarItem(icon: Icon(Icons.payment_rounded),
                    label: "Payment",
                backgroundColor: Colors.lightGreenAccent,),
                BottomNavigationBarItem(icon: Icon(Icons.home_repair_service),
                    label: "Service",
                backgroundColor: Colors.indigo,
                ),
                BottomNavigationBarItem(icon: Icon(Icons.person),
                    label: "Profile",
                backgroundColor: Colors.red,
                ),

              ])
        
        
        
            ]),
      ));
  }
}
