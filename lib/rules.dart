import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/util/AppColors.dart';
class RolesAndRegulationsScreen extends StatefulWidget {
  const RolesAndRegulationsScreen({Key? key}) : super(key: key);

  @override
  State<RolesAndRegulationsScreen> createState() => _RolesAndRegulationsScreenState();
}

class _RolesAndRegulationsScreenState extends State<RolesAndRegulationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [AppColors.background, AppColors.background],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
          color: AppColors.background
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 40,),
                     FaIcon(FontAwesomeIcons.balanceScale, size: 28, color: Colors.white),
                     SizedBox(width: 20),
                    Text(
                      "Rules & Regulations",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Introduction",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.heading,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Welcome to our application. Please adhere to the following rules and regulations to ensure a safe and respectful environment for all users.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.indigoAccent, thickness: 1),
                        const SizedBox(height: 20),

                        Text(
                          "Rules",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.heading,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "1. Admin: Responsible for managing the platform and ensuring compliance.\n"
                              "2. Service Providers: Deliver services to customers as per the agreed terms.\n"
                              "3. Customers: Use the platform responsibly and respect providers.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.indigoAccent, thickness: 1),
                        const SizedBox(height: 20),

                        Text(
                          "Regulations",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.heading,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "• Respect others and avoid abusive behavior.\n"
                              "• Ensure all transactions are conducted through the platform.\n"
                              "• Report any violations to the support team immediately.\n"
                              "• Misuse of the platform may result in suspension or ban.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),

                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
                            label: Text(
                              "Go Back",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.customButton,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
