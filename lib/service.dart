import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/serviceadd.dart'; // Ensure this path is correct for adding new service types
import 'package:servtol/util/AppColors.dart';

class servicetype extends StatefulWidget {
  const servicetype({super.key});

  @override
  State<servicetype> createState() => _servicetypeState();
}

class _servicetypeState extends State<servicetype> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot>? serviceTypesStream;

  @override
  void initState() {
    super.initState();
    serviceTypesStream = _db.collection('ServiceTypes').snapshots();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        serviceTypesStream = _db
            .collection('ServiceTypes')
            .where('Name', isGreaterThanOrEqualTo: searchController.text)
            .where('Name',
                isLessThanOrEqualTo: searchController.text + '\uf8ff')
            .snapshots();
      });
    } else {
      setState(() {
        serviceTypesStream = _db.collection('ServiceTypes').snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Service Types",
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
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins', // Added here
              ),
              decoration: InputDecoration(
                labelText: 'Search Service Types',
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
              stream: serviceTypesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Something went wrong',
                    style: TextStyle(fontFamily: 'Poppins'), // Added here
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    // Use Center for better alignment
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }
                final data = snapshot.requireData;
                return ListView.separated(
                  itemCount: data.size,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    var serviceType = data.docs[index];
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
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins', // Added here
                            ),
                          ),
                        ),
                        title: Text(
                          serviceType['Name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: AppColors.customButton),
                              onPressed: () => _showEditDialog(
                                context,
                                serviceType.id,
                                serviceType['Name'],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteServiceType(serviceType.id),
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
            context,
            MaterialPageRoute(builder: (context) => servicetypeadd()),
          );
        },
        label: Text(
          'Add Service Type',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins', // Added here
          ),
        ),
        icon: Icon(
          Icons.add,
          color: AppColors.secondaryColor,
        ),
        backgroundColor: AppColors.customButton,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _deleteServiceType(String id) {
    _db.collection('ServiceTypes').doc(id).delete();
  }

  void _showEditDialog(BuildContext context, String id, String currentName) {
    TextEditingController _nameController =
        TextEditingController(text: currentName);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Service Type'),
          content: TextField(
            controller: _nameController,
            decoration:
                InputDecoration(labelText: "Enter New Service Type Name"),
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
                  _updateServiceType(id, _nameController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateServiceType(String id, String newName) {
    _db.collection('ServiceTypes').doc(id).update({'Name': newName});
  }
}
