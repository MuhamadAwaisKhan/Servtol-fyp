import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

enum WageType { Free, Hourly, Fixed }
enum Subcategory {
  // Digital Marketing
  SEO,
  SocialMediaMarketing,
  EmailMarketing,
  ContentMarketing,

  // Online Consultation
  MedicalConsultation,
  LegalConsultation,
  FinancialConsultation,
  PsychologicalCounseling,

  // Virtual Event Management
  Webinars,
  VirtualConferences,
  OnlineWorkshops,
  VirtualConcerts,

  // Cloud Storage
  FileStorage,
  DataBackup,
  CloudHosting,
  FileSynchronization,

  // Web Development
  WebsiteDesign,
  FrontendDevelopment,
  BackendDevelopment,
  ECommerceDevelopment,

  // App Development
  MobileAppDesign,
  IOSAppDevelopment,
  AndroidAppDevelopment,
  CrossPlatformDevelopment,

  // Social Media Management
  ContentCreation,
  SocialMediaMonitoring,
  CommunityManagement,
  InfluencerMarketing,

  // SEO Optimization
  KeywordResearch,
  OnPageSEO,
  OffPageSEO,
  SEOAudits,

  // Graphic Design
  LogoDesign,
  Branding,
  Illustration,
  UIUXDesign,

  // Video Editing
  VideoProduction,
  VideoPostProduction,
  MotionGraphics,
  SpecialEffects,

  // Remote Support
  ITSupport,
  TechnicalSupport,
  CustomerService,
  HelpDeskSupport,

  // E-Commerce
  OnlineStoreSetup,
  ProductListings,
  PaymentGatewayIntegration,
  OrderManagement,

  // Virtual Training
  OnlineCourses,
  WebBasedTraining,
  VirtualTutoring,
  SkillDevelopmentPrograms,

  // Telemedicine
  OnlineDiagnosis,
  RemoteMonitoring,
  PrescriptionServices,
  Teleconsultations,

  // Remote Work
  RemoteCollaborationTools,
  VirtualTeamBuilding,
  RemoteProjectManagement,
  WorkFromHomeSolutions,

  // Mixed Reality Experience
  AugmentedReality,
  VirtualReality,
  MixedRealityGames,
  ImmersiveExperiences,

  // Virtual Tour
  ThreeSixtyDegreeTours,
  VirtualRealityTours,
  InteractiveMaps,
  DigitalShowcases,
}


enum ServiceType { Digital, Hybrid, Physical }
enum Category {
  DigitalMarketing,
  OnlineConsultation,
  VirtualEventManagement,
  CloudStorage,
  WebDevelopment,
  AppDevelopment,
  SocialMediaManagement,
  SEOOptimization,
  GraphicDesign,
  VideoEditing,
  RemoteSupport,
  ECommerce,
  VirtualTraining,
  Telemedicine,
  RemoteWork,
  MixedRealityExperience,
  VirtualTour,
  HomeCleaning,
  PlumbingService,
  ElectricianService,
  CarRepair,
  Catering,
  PersonalTraining,
  EventPlanning,
}


enum Province {
  Punjab,
  Sindh,
  Khyber_Pakhtunkhwa,
  Balochistan,
  Islamabad,
  Azad_Kashmir,
  Gilgit_Ballitan,
}

enum City {
  Lahore,
  Karachi,
  Islamabad,
  Peshawar,
  Quetta,
  Rawalpindi,
  Faisalabad,
  Multan,
  Hyderabad,
  Gujranwala,
  Sialkot,
  Abbottabad,
  Bahawalpur,
  Sukkur,
  Mardan,
  Swat,
  Gwadar,
  Gilgit,
  Skardu,
  Chitral,
  Murree,
  Sargodha,
  Sahiwal,
  Jhelum,
  Nowshera,
  Larkana,
  Kohat,
  DI_Khan,
  Mirpur,
  Mansehra,
  Rahim_Yar_Khan,
  Taxila,
  Attock,
  Kotli,
  Chakwal,
  Zhob,
  Chaman,
  Dadu,
  Bhakkar,
  Turbat,
  Haripur,
  Khuzdar,
  Timergara,
  Hafizabad,
  Nawabshah,
  Dera_Ismail_Khan,
  Mingora,
  Jhang,
  Muzaffarabad,
  Mianwali,
  Jacobabad,
  Hangu,
}

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
  Province? _selectedprovince;
   City? _selectedcity;
  WageType? _selectedWageType;
  ServiceType? _selectedservicetype;
  Category? _selectedcategory;
  Subcategory? _selectedsubcategory;

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
                  backgroundImage:
                      (profilepic != null) ? FileImage(profilepic!) : null,
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            uihelper.CustomTextField(firstcontroller, "Service Name",
                Icons.home_repair_service, false),
            SizedBox(height: 10.0),
            Container(
              width: 325,
              height: 70,
              child: DropdownButtonFormField(
                value: _selectedcategory,
                items: Category.values.map((Category) {
                  return DropdownMenuItem(
                    value: Category,
                    child: Text(Category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (Category? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedcategory = newValue;
                      _serviceTypeController.text =
                          newValue.toString().split('.').last;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: " Category",
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
            value: _selectedsubcategory,
            items: Subcategory.values.map((Subcategory) {
              return DropdownMenuItem(
                value: Subcategory,
                child: Text(Subcategory.toString().split('.').last),
              );
            }).toList(),
            onChanged: (Subcategory? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedsubcategory = newValue;
                  _serviceTypeController.text =
                      newValue.toString().split('.').last;
                });
              }
            },
            decoration: InputDecoration(
              labelText: " Sub-Category",
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
                value: _selectedprovince,
                items: Province.values.map((Province) {
                  return DropdownMenuItem(
                    value: Province,
                    child: Text(Province.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (Province? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedprovince = newValue;
                      _serviceTypeController.text =
                          newValue.toString().split('.').last;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: " Province",
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
                value: _selectedcity,
                items: City.values.map((City) {
                  return DropdownMenuItem(
                    value: City,
                    child: Text(City.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (City? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedcity = newValue;
                      _serviceTypeController.text =
                          newValue.toString().split('.').last;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: "City",
                  labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                  suffixIcon: Icon(Icons.merge_type),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            uihelper.CustomTextField(
                lastcontroller, "Service Area", Icons.compare_arrows, false),
            uihelper.CustomTextField(lastcontroller, "Service Type",
                Icons.miscellaneous_services, false),
            uihelper.CustomTextField(
                lastcontroller, "Wage Type", Icons.type_specimen, false),
            uihelper.CustomNumberField(
                cniccontroller, "Price", Icons.money_outlined, false),
            uihelper.CustomNumberField(
                cniccontroller, "Discount  ", Icons.percent_rounded, false),
            uihelper.CustomTimeDuration(
                lastcontroller, "Time Duration", Icons.timer),
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
                      _serviceTypeController.text =
                          newValue.toString().split('.').last;
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
                      _wageTypeController.text =
                          newValue.toString().split('.').last;
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
            uihelper.CustomDescritionfield(
                lastcontroller, " Description", Icons.description),
            SizedBox(
              height: 15,
            ),
            uihelper.CustomButton(() {}, "Save", 50, 170),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
