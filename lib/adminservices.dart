import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/ServiceScreenDetail.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/util/AppColors.dart';
class AdminServicesScreen extends StatefulWidget {
   AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  String searchQuery = ''; // The current search query

  // Filter variables
  String? _selectedServiceType;
  String? _selectedWageType;
  String? _selectedProvince;
  String? _selectedCategory;
  String? _selectedCity;
  String? _selectedSubCategory;

  // Temporary filter variables
  String? _tempSelectedServiceType;
  String? _tempSelectedWageType;
  String? _tempSelectedProvince;
  String? _tempSelectedCategory;
  String? _tempSelectedCity;
  String? _tempSelectedSubcategory;

  List<String> serviceTypes = [];
  List<String> wageTypes = [];
  List<String> provinces = [];
  List<String> categories = [];
  List<String> cities = [];
  List<String> subcategories = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
    _fetchFilterOptions();
  }

  Future<void> _fetchFilterOptions() async {
    try {
      var categorySnapshot = await _firestore.collection('Category').get();
      final categoryType = <String>{};
      for (var doc in categorySnapshot.docs) {
        if (doc['Name'] != null) {
          categoryType.add(doc['Name']);
        }
      }

      var provinceSnapshot = await _firestore.collection('Province').get();
      final provinceType = <String>{};
      for (var doc in provinceSnapshot.docs) {
        if (doc['Name'] != null) {
          provinceType.add(doc['Name']);
        }
      }

      var subcategorySnapshot =
      await _firestore.collection('Subcategory').get();
      final subcategoryType = <String>{};
      for (var doc in subcategorySnapshot.docs) {
        if (doc['Name'] != null) {
          subcategoryType.add(doc['Name']);
        }
      }

      var citySnapshot = await _firestore.collection('City').get();
      final cityType = <String>{};
      for (var doc in citySnapshot.docs) {
        if (doc['Name'] != null) {
          cityType.add(doc['Name']);
        }
      }

      var serviceTypesSnapshot =
      await _firestore.collection('ServiceTypes').get();
      final serviceTypeSet = <String>{};
      for (var doc in serviceTypesSnapshot.docs) {
        if (doc['Name'] != null) {
          serviceTypeSet.add(doc['Name']);
        }
      }

      var wageTypesSnapshot = await _firestore.collection('wageTypes').get();
      final wageTypeSet = <String>{};
      for (var doc in wageTypesSnapshot.docs) {
        if (doc['Name'] != null) {
          wageTypeSet.add(doc['Name']);
        }
      }

      setState(() {
        serviceTypes = serviceTypeSet.toList();
        wageTypes = wageTypeSet.toList();
        provinces = provinceType.toList();
        categories = categoryType.toList();
        cities = cityType.toList(); // Add cities to setState
        subcategories =
            subcategoryType.toList(); // Add subcategories to setState
      });
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
    bool matchesProvince = _selectedProvince == null ||
        _selectedProvince == 'All' ||
        serviceData['Province'] == _selectedProvince;
    bool matchesCategory = _selectedCategory == null ||
        _selectedCategory == 'All' ||
        serviceData['Category'] == _selectedCategory;
    bool matchesCity = _selectedCity == null || // Fix: Compare City correctly
        _selectedCity == 'All' ||
        serviceData['City'] == _selectedCity;
    bool matchesSubCategory =
        _selectedSubCategory == null || // Fix: Compare Subcategory correctly
            _selectedSubCategory == 'All' ||
            serviceData['Subcategory'] == _selectedSubCategory;
    return matchesServiceType &&
        matchesWageType &&
        matchesCategory &&
        matchesProvince &&
        matchesCity &&
        matchesSubCategory;
  }

  void _applyFilters() {
    setState(() {
      _selectedServiceType = _tempSelectedServiceType;
      _selectedWageType = _tempSelectedWageType;
      _selectedCategory = _tempSelectedCategory;
      _selectedProvince = _tempSelectedProvince;
      _selectedSubCategory = _tempSelectedSubcategory;
      _selectedCity = _tempSelectedCity;
    });
  }

  void _clearFilters() {
    setState(() {
      _tempSelectedServiceType = null;
      _tempSelectedWageType = null;
      _tempSelectedCategory = null;
      _tempSelectedProvince = null;
      _tempSelectedCity = null;
      _tempSelectedSubcategory = null;
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
        centerTitle: true,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.filter,
              color: filtersApplied ? Colors.amber : Colors.grey,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Search Services',
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                prefixIcon:
                Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                  child: Icon(Icons.clear, color: Colors.grey),
                  onTap: () {
                    searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('service')
                  .orderBy("ServiceName", descending: false)
                  .orderBy("serviceNameLower", descending: false)
                  .snapshots(),
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

                var services = snapshot.data!.docs.where((doc) {
                  var serviceData = doc.data() as Map<String, dynamic>;
                  var serviceName =
                      serviceData['ServiceName']?.toLowerCase() ?? '';
                  return serviceName.contains(searchQuery.toLowerCase()) &&
                      _matchesFilters(serviceData);
                }).toList();
                // Check if no services match the applied filters and display a message
                if (services.isEmpty) {
                  return Center(
                    child: Text(
                      'No Service match your filter criteria.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

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
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        leading: Lottie.asset(
                          _getLottieAnimationPath(serviceData['Category']),
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                        ),
                        title: Text(
                          serviceData['ServiceName'] ?? 'No name',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                          fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          serviceData['Category'] ?? 'No category',
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Colors.white70,
                              fontSize: 14,

                          ),
                        ),
                        trailing: Text(
                          "\$" + (serviceData['Price'] ?? 0).toString(),
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceDetailScreen(service: serviceDoc),
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
      case 'Home & Maintenance ':
        return 'assets/images/Home & Maintenance.json';
      case 'Hospitality':
        return 'assets/images/Hospitality.json';
      case 'Social Media Management':
        return 'assets/images/Social Media Management.json';
      case 'IT Support':
        return 'assets/images/IT Support.json';
      case 'Personal & Lifestyle ':
        return 'assets/images/Personal & Lifestyle.json';
      case 'Graphic Design':
        return 'assets/images/Graphic Design.json';
      case 'Finance':
        return 'assets/images/Finance.json';
      default:
        return 'assets/images/default.json';
    }
  }

  String? selectedFilter;

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              title: Text('Filter Options',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      isDense: true,
                      // makes the dropdown slightly more compact
                      itemHeight: 48.0,
                      value: _tempSelectedServiceType,
                      onChanged: (newValue) {
                        setDialogState(
                                () => _tempSelectedServiceType = newValue);
                      },
                      items: ['All', ...serviceTypes].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type,
                              style: TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Service Type',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      isDense: true,
                      // makes the dropdown slightly more compact
                      itemHeight: 48.0,
                      value: _tempSelectedWageType,
                      onChanged: (newValue) {
                        setDialogState(() => _tempSelectedWageType = newValue);
                      },
                      items: ['All', ...wageTypes].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type,
                              style: TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Wage Type',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      isDense: true,
                      // makes the dropdown slightly more compact
                      itemHeight: 48.0,
                      value: _tempSelectedProvince,
                      onChanged: (newValue) {
                        setDialogState(() => _tempSelectedProvince = newValue);
                      },
                      items: ['All', ...provinces].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type,
                              style: TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Province',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      isDense: true,
                      // makes the dropdown slightly more compact
                      itemHeight: 48.0,
                      value: _tempSelectedCity,
                      onChanged: (newValue) {
                        setDialogState(() => _tempSelectedCity = newValue);
                      },
                      items: ['All', ...cities].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type,
                              style: TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'City',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      isDense: true,
                      // makes the dropdown slightly more compact
                      itemHeight: 48.0,
                      value: _tempSelectedCategory,
                      onChanged: (newValue) {
                        setDialogState(() => _tempSelectedCategory = newValue);
                      },
                      items: ['All', ...categories].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type,
                              style: TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8, // Adjust the width to fit the screen
                      child: DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true, // Ensures the dropdown takes full width
                        itemHeight: 48.0,
                        value: _tempSelectedSubcategory,
                        onChanged: (newValue) {
                          setDialogState(() => _tempSelectedSubcategory = newValue);
                        },
                        items: ['All', ...subcategories].map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(fontFamily: 'Poppins'),
                              overflow: TextOverflow.ellipsis, // Truncate long text with ellipsis
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Subcategory',
                          labelStyle: TextStyle(fontFamily: 'Poppins'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearFilters();
                    filtersApplied = false;
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Clear Filters',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    setState(() {
                      filtersApplied = true;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
