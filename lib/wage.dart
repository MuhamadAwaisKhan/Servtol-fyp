import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servtol/addservices.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/wageadd.dart';

class WageTypeListScreen extends StatefulWidget {
  @override
  _WageTypeListScreenState createState() => _WageTypeListScreenState();
}

class _WageTypeListScreenState extends State<WageTypeListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot>? wageTypesStream;

  @override
  void initState() {
    super.initState();
    wageTypesStream = _db.collection('wageTypes').snapshots();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        wageTypesStream = _db.collection('wageTypes')
            .where('Name', isGreaterThanOrEqualTo: searchController.text)
            .where('Name', isLessThanOrEqualTo: searchController.text + '\uf8ff')
            .snapshots();
      });
    } else {
      setState(() {
        wageTypesStream = _db.collection('wageTypes').snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wage Types",
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
      body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Search Wage Types',
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
            SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: wageTypesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),

                    ));
                  }
                  final data = snapshot.requireData;
                  return ListView.separated(
                    itemCount: data.size,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey),
                    itemBuilder: (context, index) {
                      var wageType = data.docs[index];
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.lightBlueAccent],
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
                            child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                          ),
                          title: Text(wageType['Name'], textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.edit, color: AppColors.customButton),
                                onPressed: () => _showEditDialog(
                                    context, wageType.id, wageType['Name']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteWageType(wageType.id),
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
          ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddWageTypeScreen()));
        },
        label: Text(
          'Add Wage Type',
          style: TextStyle(color: Colors.white), // Set your text color here
        ),
        icon: Icon(
          Icons.add,
          color: AppColors.secondaryColor, // Set your icon color here
        ),
        backgroundColor: AppColors.customButton,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _deleteWageType(String id) {
    _db.collection('wageTypes').doc(id).delete();
  }

  void _showEditDialog(BuildContext context, String id, String currentName) {
    TextEditingController _nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Wage Type'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Enter New Wage Type Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: Colors.green)),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _updateWageType(id, _nameController.text);
                  Navigator.of(context). pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateWageType(String id, String newName) {
    _db.collection('wageTypes').doc(id).update({'Name': newName});
  }
}
