import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

enum WageType { Free, Hourly, Fixed }
enum ServiceType { Digital, Hybrid, Physical }

class servicesaddition extends StatefulWidget {
  const servicesaddition({super.key});

  @override
  State<servicesaddition> createState() => _servicesadditionState();
}

class _servicesadditionState extends State<servicesaddition> {
  TextEditingController firstcontroller = TextEditingController();
  TextEditingController lastcontroller = TextEditingController();
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController numbercontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController cniccontroller = TextEditingController();
  TextEditingController _wageTypeController = TextEditingController();
  TextEditingController _serviceTypeController = TextEditingController();
  File? profilepic;
  WageType _selectedWageType = WageType.Hourly;
  ServiceType _selectedservicetype = ServiceType.Digital; // Provide a default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Your Services",
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                XFile? selectedImage = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );

                if (selectedImage != null) {
                  File convertedfile = File(selectedImage.path);
                  uihelper.CustomAlertbox(context, "Image Selected!");
                  setState(() {
                    profilepic = convertedfile;
                  });
                } else {
                  uihelper.CustomAlertbox(context, "No Image Selected!");
                }
              },
              child: Center(
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.grey,
                  backgroundImage: (profilepic != null) ? FileImage(profilepic!) : null,
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            uihelper.CustomTextField(firstcontroller, "Service Name", Icons.home_repair_service, false),
            uihelper.CustomTextField(lastcontroller, "Service Category", Icons.category_rounded, false),
            uihelper.CustomTextField(lastcontroller, "Service Sub-Category", Icons.subdirectory_arrow_right_outlined, false),
            uihelper.CustomTextField(lastcontroller, "Service State", Icons.real_estate_agent_outlined, false),
            uihelper.CustomTextField(lastcontroller, "Service City", Icons.location_city_outlined, false),
            uihelper.CustomTextField(lastcontroller, "Service Area", Icons.compare_arrows, false),
            uihelper.CustomTextField(lastcontroller, "Service Type", Icons.miscellaneous_services, false),
            uihelper.CustomTextField(lastcontroller, "Wage Type", Icons.type_specimen, false),
            uihelper.CustomNumberField(cniccontroller, "Price", Icons.money_outlined, false),
            uihelper.CustomNumberField(cniccontroller, "Discount  ", Icons.percent_rounded, false),
            uihelper.CustomTimeDuration(lastcontroller, "Time Duration", Icons.timer),

            SizedBox(height: 10.0),
            Container(
              width: 325,
              height: 70,
              child: DropdownButtonFormField(
                value: _selectedservicetype,
                items: ServiceType.values.map((serviceType) {
                  return DropdownMenuItem(
                    value: serviceType,
                    child: Text(serviceType.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (ServiceType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedservicetype = newValue;
                      _serviceTypeController.text = newValue.toString().split('.').last;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: "Service type",
                  labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                  suffixIcon: Icon(Icons.merge_type),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              width: 325,
              height: 70,
              child: DropdownButtonFormField(
                value: _selectedWageType,
                items: WageType.values.map((wageType) {
                  return DropdownMenuItem(
                    value: wageType,
                    child: Text(wageType.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (WageType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedWageType = newValue;
                      _wageTypeController.text = newValue.toString().split('.').last;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: "Wage type",
                  labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                  suffixIcon: Icon(Icons.merge_type),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            uihelper.CustomDescritionfield(lastcontroller, " Description", Icons.description),
            SizedBox(height: 15,),
            uihelper.CustomButton(() { }, "Save",50, 170),
            SizedBox(height: 15,),
          ],
        ),
      ),
    );
  }
}
