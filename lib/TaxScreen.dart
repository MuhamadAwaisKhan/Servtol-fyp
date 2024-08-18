import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxScreen extends StatefulWidget {
  @override
  _TaxScreenState createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void showTaxDialog({Map<String, dynamic>? taxData, String? documentId}) {
    final _rateController = TextEditingController(text: taxData?['rate'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(taxData == null ? 'Add Tax' : 'Edit: ${taxData['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Only show the name field when adding a new tax
            if (taxData == null)
              TextField(
                controller: TextEditingController(text: taxData?['name']),
                decoration: InputDecoration(labelText: 'Tax Name'),
              ),
            TextField(
              controller: _rateController,
              decoration: InputDecoration(labelText: 'Tax Rate (%)'),
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
            child: Text(taxData == null ? 'Add' : 'Update'),
            onPressed: () {
              final rate = double.tryParse(_rateController.text);
              if (rate != null) {
                final Map<String, dynamic> updatedTax = {'rate': rate};
                if (documentId == null) {
                  _firestore.collection('taxes').add({
                    'name': _rateController.text, // Assuming name is also handled here for new tax
                    'rate': rate
                  });
                } else {
                  _firestore.collection('taxes').doc(documentId).update(updatedTax);
                }
                Navigator.pop(context);
              }
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
        title: Text('Tax Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('taxes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> tax = doc.data() as Map<String, dynamic>;
              return Card(
                color: Colors.grey[850],
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  title: Text(tax['name'], style: TextStyle(color: Colors.white)),
                  subtitle: Text('${tax['rate']}%', style: TextStyle(color: Colors.grey[400])),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.green),
                        onPressed: () => showTaxDialog(taxData: tax, documentId: doc.id),
                      ),
                      // IconButton(
                      //   icon: Icon(Icons.delete, color: Colors.red),
                      //   onPressed: () {
                      //     _firestore.collection('taxes').doc(doc.id).delete();
                      //   },
                      // ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaxDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
