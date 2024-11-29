import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/util/AppColors.dart';
class CategoryServicesScreen extends StatefulWidget {
  final String categoryName;

  CategoryServicesScreen({required this.categoryName});

  @override
  _CategoryServicesScreenState createState() => _CategoryServicesScreenState();
}
class _CategoryServicesScreenState extends State<CategoryServicesScreen> {
  List<String> subcategories = [];
  String? selectedSubcategory;
  List<QueryDocumentSnapshot> services = [];
  bool filtersApplied = false; // Tracks if filters are applied

  @override
  void initState() {
    super.initState();
    fetchSubcategories();
    fetchServices();
  }
  void fetchSubcategories() async {
    // Step 1: Fetch the categoryID for the selected category name
    var categorySnapshot = await FirebaseFirestore.instance
        .collection('Category')
        .where('Name', isEqualTo: widget.categoryName)
        .get();

    if (categorySnapshot.docs.isNotEmpty) {
      var categoryID = categorySnapshot.docs.first.id;

      // Step 2: Fetch subcategories based on the fetched categoryID
      var subcategorySnapshot = await FirebaseFirestore.instance
          .collection('Subcategory')
          .where('categoryId', isEqualTo: categoryID)
          .get();

      setState(() {
        subcategories = subcategorySnapshot.docs.map((doc) => doc['Name'] as String).toList();
      });
    } else {
      print('No category found with the name: ${widget.categoryName}');
    }
  }
  void fetchServices() async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('service')
          .where('Category', isEqualTo: widget.categoryName);

      if (selectedSubcategory != null && selectedSubcategory!.isNotEmpty) {
        query = query.where('Subcategory', isEqualTo: selectedSubcategory);
      }

      var snapshot = await query.get();
      setState(() {
        services = snapshot.docs;
        filtersApplied = selectedSubcategory != null;
      });

      // If no services found and no filter applied, reset filtersApplied to false
      if (services.isEmpty && selectedSubcategory == null) {
        setState(() {
          filtersApplied = false;
        });
      }
    } catch (e) {
      print('Error fetching services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.filter,
              color: filtersApplied ? Colors.amber : Colors.grey,
            ),
            onPressed: () => _showFilterDialog(),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,

      body: services.isEmpty
          ? Center(
        child: Text(
          filtersApplied
              ? 'No Service match your filter criteria.'
              : 'No Service available for this category.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          var service = services[index];
          String category = service['Category'] ?? 'No category';
          String lottieAnimationPath = _getLottieAnimationPath(category);

          return Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              leading: Lottie.asset(
                lottieAnimationPath,
                height: 100,
                width: 100,
                fit: BoxFit.fill,
              ),
              title: Text(
                service['ServiceName'] ?? 'No name',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                service['Category'] ?? 'No category',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
              ),
              trailing: Text(
                "\u20A8 " + (service['Price']?.toString() ?? 'No Price'),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Servicecustomerdetail(service: service),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Filter by Subcategory",
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Category: ${widget.categoryName}",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedSubcategory,
                decoration: InputDecoration(
                  labelText: "Select Subcategory",
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: subcategories.map((subcategory) {
                  return DropdownMenuItem<String>(
                    value: subcategory,
                    child: Text(
                      subcategory,
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubcategory = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedSubcategory = null;
                  filtersApplied = false;
                });
                fetchServices(); // Refresh services list
                Navigator.pop(context);
              },
              child: Text(
                "Clear Filter",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                fetchServices();
                Navigator.pop(context);
              },
              child: Text(
                "Apply",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getLottieAnimationPath(String category) {
    switch (category) {
      case 'Online Services':
        return 'assets/images/onlineservice.json';
      case 'Development':
        return 'assets/images/development.json';
      case 'Healthcare':
        return 'assets/images/healthcare.json';
      case 'Design & Multimedia':
        return 'assets/images/designmulti.json';
      case 'Telemedicine':
        return 'assets/images/Telemedicine.json';
      case 'Education':
        return 'assets/images/education.json';
      case 'Retail':
        return 'assets/images/Retail.json';
      case 'Online Consultation':
        return 'assets/images/Online Consultation.json';
      case 'Digital Marketing':
        return 'assets/images/Digital Marketing.json';
      case 'Online Training':
        return 'assets/images/onlineservice.json';
      case 'Event Management':
        return 'assets/images/Event Management.json';
      case 'Video Editing':
        return 'assets/images/Graphic Design.json';
      case 'Home & Maintenance':
        return 'assets/images/Home & Maintenance.json';
      case 'Hospitality':
        return 'assets/images/Hospitality.json';
      case 'Social Media Management':
        return 'assets/images/Social Media Management.json';
      case 'IT Support':
        return 'assets/images/IT Support.json';
      case 'Personal & Lifestyle':
        return 'assets/images/Personal & Lifestyle.json';
      case 'Graphic Design':
        return 'assets/images/Graphic Design.json';
      case 'Finance':
        return 'assets/images/Finance.json';
      default:
        return 'assets/images/default.json';
    }
  }

}
