import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/util/AppColors.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  void _searchServices(String query) async {
    if (query.isNotEmpty) {
      query = query
          .toLowerCase(); // Convert query to lowercase for case-insensitive search
      var result = await _firestore
          .collection('service')
          .where('serviceNameLower', isGreaterThanOrEqualTo: query)
          .where('serviceNameLower', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      setState(() {
        _searchResults = result.docs;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Services',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Search Services',
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                  prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass,
                      color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          child: Icon(Icons.clear, color: Colors.grey),
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
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
                onChanged: (query) => _searchServices(query.trim()),
              ),
            ),
            SizedBox(height: 20),
            // Display Results
            Expanded(
              child: _searchResults.isNotEmpty
                  ? ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var service = _searchResults[index].data() as Map<String, dynamic>;
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
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      leading: Lottie.asset(
                        _getLottieAnimationPath(service['Category']),
                        height: 100,
                        width: 100,
                        fit: BoxFit.fill,
                      ),
                      title: Text(
                        service['ServiceName'] ?? 'No name',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        service['Category'] ?? 'No category',
                        style: TextStyle(
                            fontFamily: 'Poppins', color: Colors.white70),
                      ),
                      trailing: Text(
                        "\$" + (service['Price'] ?? 0).toString(),
                        style: TextStyle(
                            fontFamily: 'Poppins', color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Servicecustomerdetail(
                                service: _searchResults[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  searchQuery.isEmpty
                      ? 'Start typing to search for services.'
                      : 'No services found for "$searchQuery".',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
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
