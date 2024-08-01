import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servtol/wageadd.dart';

class WageTypeListScreen extends StatefulWidget {
  @override
  _WageTypeListScreenState createState() => _WageTypeListScreenState();
}

class _WageTypeListScreenState extends State<WageTypeListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wage Types"),
        backgroundColor: Colors.deepPurple, // Customize your app bar color here
      ),
      body: StreamBuilder(
        stream: _db.collection('wageTypes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final data = snapshot.requireData;
          return ListView.separated(
            itemCount: data.size,
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              var wageType = data.docs[index];
              return ListTile(
                title: Text(wageType['Name'], style: TextStyle(fontWeight: FontWeight.bold)),
                // subtitle: Text("Tap to edit or delete", style: TextStyle(color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, wageType.id, wageType['Name']), // Changed 'name' to 'Name'
                    ),

                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteWageType(wageType.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWageTypeScreen()),
          ).then((value) => setState(() {}));
        },
        tooltip: 'Add Wage Type',
        child: Icon(Icons.add),
        backgroundColor: Colors.green, // Customize your floating action button color here
      ),
    );
  }

  void _deleteWageType(String id) {
    _db.collection('wageTypes').doc(id).delete();
  }

  void _showEditDialog(BuildContext context, String id, String currentName) {
    TextEditingController _nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Wage Type'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: "Enter New Wage Type Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: Colors.green)),
              onPressed: () {
                _updateWageType(id, _nameController.text);
                Navigator.of(context).pop();
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
