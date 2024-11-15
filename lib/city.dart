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
    citiesStream = _db.collection('City')
        .orderBy('Name', descending: false) // Fetch data in ascending order by name

        .snapshots();
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
        citiesStream = _db
            .collection('City')
            .where('Name', isGreaterThanOrEqualTo: searchController.text)
            .where('Name',
                isLessThanOrEqualTo: searchController.text + '\uf8ff')
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
        title: Text("City",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.heading)),
        backgroundColor: AppColors.background,
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
                labelText: 'Search City',
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
                if (snapshot.connectionState == ConnectionState.waiting)
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  );
                final data = snapshot.requireData;
                return ListView.separated(
                  itemCount: data.size,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    var city = data.docs[index];
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.lightBlueAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${index + 1}',
                              style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(city['Name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: AppColors.customButton),
                              onPressed: () => _showEditDialog(context, city.id,
                                  city['Name'], city['provinceId']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteServiceType(city.id),
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CityAdd()));
        },
        label: Text('Add City', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: AppColors.secondaryColor),
        backgroundColor: AppColors.customButton,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _deleteServiceType(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text(
                'Confirm Delete',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this city? This action cannot be undone.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                _db.collection('City').doc(id).delete(); // Perform delete
                Navigator.of(context).pop(); // Close the dialog after delete
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditDialog(BuildContext context, String subcategoryId, String currentName, String currentCategoryId) {
    TextEditingController nameController = TextEditingController(text: currentName);
    String? selectedCategoryId = currentCategoryId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 28),
              SizedBox(width: 8),
              Text(
                'Edit Subcategory',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'City Name',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                onChanged: (newValue) {
                  selectedCategoryId = newValue;
                },
                items: provinceItems,
                decoration: InputDecoration(
                  labelText: 'Select Province',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () async {
                if (selectedCategoryId == null) {
                  print('Category ID is null');
                  return;
                }

                // Show confirmation dialog before saving
                bool confirmSave = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Confirm Save',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      content: Text(
                        'Are you sure you want to save these changes?',
                        style: TextStyle(fontFamily: 'Poppins', color: Colors.black87),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: Text('Yes', style: TextStyle(color: Colors.green, fontFamily: 'Poppins')),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                ) ?? false;

                if (confirmSave) {
                  _updateCity(subcategoryId, nameController.text, selectedCategoryId!);
                  Navigator.pop(context); // Close the main dialog after saving
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.green, fontFamily: 'Poppins')),
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
