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
    serviceTypesStream = _db.collection('ServiceTypes')
        .orderBy('Name', descending: false) // Fetch data in ascending order by name
        .snapshots();
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
            'Are you sure you want to delete this service type? This action cannot be undone.',
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
                _db.collection('ServiceTypes').doc(id).delete(); // Perform delete
                Navigator.of(context).pop(); // Close the dialog after delete
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditDialog(BuildContext context, String id, String currentName) {
    TextEditingController _nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 30),
              SizedBox(width: 10),
              Text(
                'Edit Service Type',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: TextStyle(fontFamily: 'Poppins', color: Colors.black87),
                decoration: InputDecoration(
                  labelText: "Enter New Service Type Name",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.green, fontFamily: 'Poppins'),
              ),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  // Ask for confirmation before saving
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
                            SizedBox(width: 10),
                            Text(
                              'Confirm Edit',
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        content: Text(
                          'Are you sure you want to save the changes?',
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.black87),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'No',
                              style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text(
                              'Yes',
                              style: TextStyle(color: Colors.green, fontFamily: 'Poppins'),
                            ),
                            onPressed: () {
                              _updateServiceType(id, _nameController.text);
                              Navigator.of(context).pop(); // Close confirmation dialog
                              Navigator.of(context).pop(); // Close edit dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
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
