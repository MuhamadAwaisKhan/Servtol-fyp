import 'package:flutter/material.dart';
import 'package:servtol/main%20login.dart';
import 'package:servtol/servtolsplashscreen.dart';
import 'package:servtol/util/AppColors.dart';
class startingscreen extends StatefulWidget {
  const startingscreen({super.key});

  @override
  State<startingscreen> createState() => _startingscreenState();
}

class _startingscreenState extends State<startingscreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(backgroundColor: AppColors.background,),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/startlogo.jpeg'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Welcome to Servtol',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your one-stop destination for all your service needs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ServToolSplashScreen()));
                  // Navigate to your desired screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.customButton,
                  foregroundColor: Colors.white,


                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Let\'s Get Started',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

    );}
}