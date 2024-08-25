import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TaxScreen extends StatefulWidget {
  @override
  _TaxScreenState createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void showEntryDialog({Map<String, dynamic>? entryData, String? documentId, required bool isTax}) {
    TextEditingController nameController = TextEditingController(text: entryData?['name']);
    TextEditingController rateController = TextEditingController(text: entryData?['rate'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isTax ? 'Manage Tax Rate' : 'Manage Booking Fee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField(
              //   controller: nameController,
              //   decoration: InputDecoration(labelText: 'Name'),
              // ),
              TextField(
                controller: rateController,
                decoration: InputDecoration(
                    labelText: isTax ? 'Tax Rate (%)' : 'Booking Fee \$'
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(entryData == null ? 'Add' : 'Update'),
              onPressed: () {
                final value = double.tryParse(rateController.text) ?? 0;
                Map<String, dynamic> updatedEntry = {
                  'name': nameController.text,
                  'rate': value
                };
                String collectionPath = isTax ? 'taxRates' : 'bookingFees';
                if (documentId == null) {
                  _firestore.collection(collectionPath).add(updatedEntry);
                } else {
                  _firestore.collection(collectionPath).doc(documentId).update(updatedEntry);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildList(String title, String collectionPath, bool isTax) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection(collectionPath).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.blue,
                    elevation: 5,
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${data['rate']}${isTax ? '%' : '\$'}', style: TextStyle(color: Colors.grey[600])),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () => showEntryDialog(entryData: data, documentId: doc.id, isTax: isTax),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _firestore.collection(collectionPath).doc(doc.id).delete(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Fee Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          buildList('Tax Rates', 'taxRates', true),
          buildList('Booking Fees', 'bookingFees', false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showEntryDialog(isTax: true),  // Default to adding a new tax rate
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
