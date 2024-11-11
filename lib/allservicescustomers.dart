import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/util/AppColors.dart';

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  String searchQuery = ''; // The current search query

  // Filter variables
  String? _selectedServiceType;
  String? _selectedWageType;

  // Temporary filter variables
  String? _tempSelectedServiceType;
  String? _tempSelectedWageType;

  List<String> serviceTypes = [];
  List<String> wageTypes = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
    _firestore = FirebaseFirestore.instance;
    // print("abc");
    _fetchFilterOptions();
  }

  Future<void> _fetchFilterOptions() async {
    try {
      // print("Fetching service types and wage types...");

      // Fetching service types from the 'servicetypes' collection
      var serviceTypesSnapshot = await _firestore.collection('ServiceTypes').get();
      final types = <String>{};
      print(serviceTypesSnapshot.docs.length);
      for (var doc in serviceTypesSnapshot.docs) {
        print("ServiceType document: ${doc.data()}");
        if (doc['Name'] != null) {
          types.add(doc['Name']);
        }
      }

      // Fetching wage types from the 'wagetypes' collection
      var wageTypesSnapshot = await _firestore.collection('wageTypes').get();
      final wages = <String>{};

      for (var doc in wageTypesSnapshot.docs) {
        print("WageType document: ${doc.data()}");
        if (doc['Name'] != null) {
          wages.add(doc['Name']);
        }
      }

      setState(() {
        serviceTypes = types.toList();
        wageTypes = wages.toList();
      });
    //
    //   print("Fetched service types: $serviceTypes");
    //   print("Fetched wage types: $wageTypes");
    } catch (error) {
      print('Error fetching filter options: $error');
    }
  }

  bool _matchesFilters(Map<String, dynamic> serviceData) {
    bool matchesServiceType = _selectedServiceType == null ||
        _selectedServiceType == 'All' ||
        serviceData['ServiceType'] == _selectedServiceType;
    bool matchesWageType = _selectedWageType == null ||
        _selectedWageType == 'All' ||
        serviceData['WageType'] == _selectedWageType;
    return matchesServiceType && matchesWageType;
  }
  void _applyFilters() {
    setState(() {
      _selectedServiceType = _tempSelectedServiceType;
      _selectedWageType = _tempSelectedWageType;
    });
  }

  void _clearFilters() {
    setState(() {
      _tempSelectedServiceType = null;
      _tempSelectedWageType = null;
      _applyFilters();
    });
  }
  bool filtersApplied = false; // Tracks if filters are applied

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Services',
          style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.heading,
              fontWeight: FontWeight.bold,
              fontSize: 17),
        ),
        backgroundColor: AppColors.background,
        actions: [
      IconButton(
      icon: FaIcon(
      FontAwesomeIcons.filter,
        color: filtersApplied ? Colors.amber : Colors.grey,
      ),
      onPressed: () {
              // Print service and wage types when the filter icon is clicked
              // print("Service Types: $serviceTypes");
              // print("Wage Types: $wageTypes");

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Filter Services"),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            hint: Text("Select Service Type"),
                            value: _tempSelectedServiceType,
                            onChanged: (newValue) {
                              setState(() {
                                _tempSelectedServiceType = newValue;
                              });
                            },
                            items: serviceTypes
                                .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                                .toList(),
                          ),
                          DropdownButton<String>(
                            hint: Text("Select Wage Type"),
                            value: _tempSelectedWageType,
                            onChanged: (newValue) {
                              setState(() {
                                _tempSelectedWageType = newValue;
                              });
                            },
                            items: wageTypes
                                .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        child: Text('Apply Filters'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearFilters();
                        },
                        child: Text('Clear Filters'),
                      ),
                    ],
                  );
                },
              );

            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          // Search Field
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Search Services',
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                prefixIcon: Icon(FontAwesomeIcons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                  child: Icon(Icons.clear, color: Colors.grey),
                  onTap: () {
                    searchController.clear();
                    setState(() {}); // Refresh the search when cleared
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // StreamBuilder to fetch and filter services based on the search query
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('service').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No services found.'));
                }

                // Filter services by search query and selected filters
                var services = snapshot.data!.docs
                    .where((doc) {
                  var serviceData = doc.data() as Map<String, dynamic>;
                  var serviceName = serviceData['ServiceName']?.toLowerCase() ?? '';
                  return serviceName.contains(searchQuery.toLowerCase()) &&
                      _matchesFilters(serviceData);
                })
                    .toList();

                return ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    var serviceDoc = services[index];
                    var serviceData = serviceDoc.data() as Map<String, dynamic>;

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
                          _getLottieAnimationPath(serviceData['Category']),
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                        ),
                        title: Text(
                          serviceData['ServiceName'] ?? 'No name',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          serviceData['Category'] ?? 'No category',
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
                        ),
                        trailing: Text(
                          "\$" + (serviceData['Price'] ?? 0).toString(),
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Servicecustomerdetail(service: serviceDoc, ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
