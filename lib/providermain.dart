import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class providermainlayout extends StatefulWidget {
  const providermainlayout({super.key});

  @override
  State<providermainlayout> createState() => _providermainlayoutState();
}

class _providermainlayoutState extends State<providermainlayout> {
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
      body: Column(

        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 229.0),
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
              Padding(
                padding: const EdgeInsets.only(right: 249.0),
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
          SizedBox(height: 5,),
          Column(
            children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        uihelper.CustomButton(() { }, "Booking"),
                        uihelper.CustomButton(() { }, "Total Service")
                      ],
                    ),
                SizedBox(height: 10,),
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
        ],
      ),
    );
  }
}
