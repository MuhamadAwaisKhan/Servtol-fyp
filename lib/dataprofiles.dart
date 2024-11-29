import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/customeradmin.dart';
import 'package:servtol/provideradmin.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class dataprofiles extends StatefulWidget {
  const dataprofiles({super.key});

  @override
  State<dataprofiles> createState() => _dataprofilesState();
}

class _dataprofilesState extends State<dataprofiles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,

      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Lottie.asset(
                  'assets/images/onlineservice.json',
                  height: 200,
                  fit: BoxFit.cover,
                ), ),
              SizedBox(
                height: 15,
              ),

              uihelper.CustomButton(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CustomerScreen()),
                      );
                },
                "Customer Management",
                40,
                240,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProviderScreen()),
                      );
                    },
                "Provider Management",
                40,
                240,
              ),
              SizedBox(
                height: 20,
              ),


            ],
          ),
        ),
      ),
    );
  }
}
