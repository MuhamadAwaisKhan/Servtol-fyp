import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/cityadd.dart';
import 'package:servtol/util/AppColors.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({Key? key}) : super(key: key);

  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot>? citiesStream;
  List<DropdownMenuItem<String>> provinceItems = [];

  @override
  void initState() {
    super.initState();
    citiesStream = _db.collection('City').snapshots();
    fetchProvinces();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchProvinces() async {
    var provincesSnapshot = await _db.collection('Province').get();
    var items = provincesSnapshot.docs.map((doc) {
      return DropdownMenuItem<String>(
        value: doc.id,
        child: Text(doc.data()['Name'] ?? 'Unnamed Province'),
      );
    }).toList();

    if (mounted) {
      setState(() {
        provinceItems = items;
      });
    }
  }

  void _onSearchChanged() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        citiesStream = _db.collection('City')
            .where('Name', isGreaterThanOrEqualTo: searchController.text)
            .where('Name', isLessThanOrEqualTo: searchController.text + '\uf8ff')
            .snapshots();
      });
    } else {
      setState(() {
        citiesStream = _db.collection('City').snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("City", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.heading)),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body:  Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Search Provinces',
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                  child: Icon(Icons.clear, color: Colors.grey),
                  onTap: () {
                    searchController.clear();
                    _onSearchChanged(); // Refresh the search
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
                _onSearchChanged(); // Trigger rebuild with every change
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: citiesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Something went wrong');
                if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
                final data = snapshot.requireData;
                return ListView.separated(
                  itemCount: data.size,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    var city = data.docs[index];
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(city['Name'], textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(context, city.id, city['Name'], city['provinceId']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCity(city.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CityAdd()));
        },
        label: Text('Add City', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: AppColors.secondaryColor),
        backgroundColor: AppColors.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _deleteCity(String id) {
    _db.collection('City').doc(id).delete();
  }

  void _showEditDialog(BuildContext context, String cityId, String currentName, String currentProvinceId) {
    TextEditingController nameController = TextEditingController(text: currentName);
    String? selectedProvinceId = currentProvinceId;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit City'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'City Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedProvinceId,
                onChanged: (newValue) {
                  setState(() {
                    selectedProvinceId = newValue;
                  });
                },
                items: provinceItems,
                decoration: InputDecoration(labelText: 'Select Province'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (selectedProvinceId != null) {
                  _updateCity(cityId, nameController.text, selectedProvinceId!);
                  Navigator.pop(context);
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _updateCity(String cityId, String newName, String newProvinceId) {
    _db.collection('City').doc(cityId).update({
      'Name': newName,
      'provinceId': newProvinceId,
    });
  }
}
