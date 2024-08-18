import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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

class editservice extends StatefulWidget {

  String serviceId;
  String sericename;
  String category;
  String Subcategory;
  String Province;
  String City;
  String Area;
  String ServiceType;
  String WageType;
  String Price;
  String Discount;
  String TimeSlot;
  String Description;


  editservice({super.key,
    required this.serviceId,
    required this.sericename,
  required this.category,
  required this.Subcategory,
  required this.Province,
  required this.Price,
  required this.City,
  required this.Area,
  required this.ServiceType,
  required this.WageType,
  required this.Discount,
  required this.TimeSlot,
  required this.Description,


  });


  @override
  State<editservice> createState() => _editserviceState();
}

class _editserviceState extends State<editservice> {
  TextEditingController snanmecontroller = TextEditingController();
  TextEditingController categorycontroller = TextEditingController();
  TextEditingController subcategorycontroller = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  TextEditingController provincecontroller = TextEditingController();
  TextEditingController areacontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController timecontroller = TextEditingController();
  TextEditingController discountcontroller = TextEditingController();
  TextEditingController _wageTypeController = TextEditingController();
  TextEditingController _serviceTypeController = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  File? profilepic;
  Province? _selectedprovince;
  City? _selectedcity;
  WageType? _selectedWageType;
  ServiceType? _selectedservicetype;
  Category? _selectedcategory;
  Subcategory? _selectedsubcategory;



  @override

  Widget build(BuildContext context) {
    Future<String> _uploadImageToFirebaseStorage() async {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = FirebaseStorage.instance
            .ref()
            .child('images/Servicepics/$fileName.jpg');
        UploadTask uploadTask = reference.putFile(profilepic!);
        TaskSnapshot storageTaskSnapshot = await uploadTask;
        String downloadURL = await storageTaskSnapshot.ref.getDownloadURL();
        return downloadURL;
      } catch (e) {
        throw Exception('Failed to upload image to Firebase Storage: $e');
      }
    }

    Future<void> _updateService(String documentId) async {
      try {
        // Validation checks
        if (profilepic == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid Service Picture')),
          );
        }
        if (snanmecontroller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid Service Name')),
          );
        }
        if (timecontroller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid Time Slot')),
          );
        }
        if (_selectedcategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid Category')),
          );
        }
        if (_selectedsubcategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid  Sub-Category')),
          );
        }
        if (_selectedprovince == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid  Province')),
          );
        }
        if (_selectedcity == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid  City')),
          );
        }
        if (areacontroller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid  Area')),
          );
        }
        if (pricecontroller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid Price')),
          );
        }
        if (discountcontroller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid  Discount %')),
          );
        }
        if (_selectedWageType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid  Wage Type')),
          );
        }
        if (_selectedservicetype == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid  Service Type')),
          );
        }
        if (descriptioncontroller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid Description')),
          );
        }
        await FirebaseAppCheck.instance.activate();

        // Upload image to Firebase Storage
        String imageUrl = await _uploadImageToFirebaseStorage();

        // Save image URL and service details to Firestore
        await FirebaseFirestore.instance.collection('service').doc(documentId).update({
          'ServiceName': snanmecontroller.text.trim(),
          'Category': categorycontroller.text.trim(),
          'Subcategory': subcategorycontroller.text.trim(),
          'Province': provincecontroller.text.trim(),
          'City': citycontroller.text.trim(),
          'Area': areacontroller.text.trim(),
          'Price': pricecontroller.text.trim(),
          'Discount': discountcontroller.text.trim(),
          'WageType': _wageTypeController.text.trim(),
          'ServiceType': _serviceTypeController.text.trim(),
          'Description': descriptioncontroller.text.trim(),
          'ImageUrl': imageUrl,
          'TimeSlot': timecontroller.text.trim(),
        });

        setState(() {
          profilepic = null;
          snanmecontroller.clear();
          _selectedcategory = null;
          _selectedservicetype = null;
          _selectedsubcategory = null;
          _selectedprovince = null;
          _selectedcity = null;
          areacontroller.clear();
          pricecontroller.clear();
          discountcontroller.clear();
          _selectedWageType = null;
          _selectedservicetype = null;
          descriptioncontroller.clear();
          timecontroller.clear();
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service Edited successfully')),
        );
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit service: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Update  Services",
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
            uihelper.CustomTextField(snanmecontroller, "Service Name",
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
                      categorycontroller.text =
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
                      subcategorycontroller.text =
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
                      provincecontroller.text =
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
                      citycontroller.text = newValue.toString().split('.').last;
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
                areacontroller, "Area", Icons.area_chart, false),
            uihelper.CustomNumberField(
                pricecontroller, "Price", Icons.money_outlined, false),
            uihelper.CustomNumberField(
                discountcontroller, "Discount  ", Icons.percent_rounded, false),
            uihelper.CustomTimeDuration(timecontroller, "Time Duration",
                Icons.timer, "hour:min==00:00"),
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
            uihelper.customDescriptionField(
                descriptioncontroller, " Description"),
            SizedBox(
              height: 15,
            ),
            uihelper.CustomButton(() {
              _updateService(widget.serviceId);
            }, "Edit Service", 50, 170),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
