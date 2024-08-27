import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxScreen extends StatefulWidget {
  @override
  _TaxScreenState createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void showActionSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.monetization_on),
                    title: Text('Add Tax Rate'),
                    onTap: () {
                      Navigator.pop(context);
                      showEntryDialog(context: context, isTax: true);
                    }),
                ListTile(
                  leading: Icon(Icons.card_giftcard),
                  title: Text('Add Booking Fee'),
                  onTap: () {
                    Navigator.pop(context);
                    showEntryDialog(context: context, isTax: false);
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  void showEntryDialog({BuildContext? context, Map<String, dynamic>? entryData, String? documentId, required bool isTax}) {
    TextEditingController nameController = TextEditingController(text: entryData?['name'] ?? '');
    TextEditingController rateController = TextEditingController(text: entryData?['rate'].toString() ?? '');

    showDialog(
      context: context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isTax ? 'Manage Tax Rate' : 'Manage Booking Fee'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: rateController,
                  decoration: InputDecoration(labelText: isTax ? 'Tax Rate (%)' : 'Booking Fee (\$)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(entryData == null ? 'Add' : 'Update'),
              onPressed: () async {
                final double value = double.tryParse(rateController.text) ?? 0;
                Map<String, dynamic> updatedEntry = {
                  'name': nameController.text.trim(),
                  'rate': value,
                };

                String collectionPath = isTax ? 'taxRates' : 'bookingFees';
                try {
                  DocumentReference ref;
                  if (documentId == null) {
                    ref = await _firestore.collection(collectionPath).add(updatedEntry);
                    // Update the document to include its own ID
                    await ref.update({'id': ref.id});
                    print("Added new entry with ID: ${ref.id}");
                  } else {
                    ref = _firestore.collection(collectionPath).doc(documentId);
                    await ref.update(updatedEntry);
                    print("Updated entry with ID: $documentId");
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error: $e");
                }
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
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return Card(
                        color: Colors.blue[100],
                        child: ListTile(
                          title: Text(data['name']),
                          subtitle: Text('${data['rate']}${isTax ? '%' : '\$'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => showEntryDialog(
                                  context: context,
                                  entryData: data,
                                  documentId: document.id,
                                  isTax: isTax,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _firestore.collection(collectionPath).doc(document.id).delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
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
        title: Text('Fee Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          buildList('Tax Rates', 'taxRates', true),
          buildList('Booking Fees', 'bookingFees', false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showActionSheet(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
