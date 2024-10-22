import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class TimeSlotScreen extends StatefulWidget {
  final String providerId;

  TimeSlotScreen({required this.providerId});

  @override
  _TimeSlotScreenState createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  TextEditingController _timeSlotController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Time Slots',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: AppColors.heading,),),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            uihelper.CustomTextField1(context, _timeSlotController, 'Enter Time Slot','e.g., 10:00 AM - 12:00 PM', FontAwesomeIcons.accusoft, ),

            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue,),
            )
                : uihelper.CustomButton((){
                  addTimeSlot();
            }, 'Add Time Slot', 50, 170),
           
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('provider')
                    .doc(widget.providerId)
                    .collection('timeSlots')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  }

                  var timeSlots = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      var timeSlot = timeSlots[index];
                      return Card(
                        color: Colors.blue,
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${index + 1}',
                                style: TextStyle(color: Colors.white)),
                          ),
                          title: Text(
                            timeSlot['slot'],
                            style: TextStyle(fontSize: 16.0, fontFamily:'Poppins',fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.edit, color: Colors.white),
                                onPressed: () {
                                  _editTimeSlotDialog(timeSlot.id, timeSlot['slot']);
                                },
                              ),
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.trashCan, color: Colors.red),
                                onPressed: () => deleteTimeSlot(timeSlot.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> addTimeSlot() async {
    if (_timeSlotController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Time slot cannot be empty");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('provider')
          .doc(widget.providerId)
          .collection('timeSlots')
          .add({
        'slot': _timeSlotController.text,
      });
      Fluttertoast.showToast(msg: "Time slot added successfully");
      _timeSlotController.clear();
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to add time slot: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> deleteTimeSlot(String slotId) async {
    try {
      await FirebaseFirestore.instance
          .collection('provider')
          .doc(widget.providerId)
          .collection('timeSlots')
          .doc(slotId)
          .delete();
      Fluttertoast.showToast(msg: "Time slot deleted");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete time slot: $e");
    }
  }

  Future<void> _editTimeSlotDialog(String slotId, String currentSlot) async {
    TextEditingController _editTimeSlotController =
    TextEditingController(text: currentSlot);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Time Slot"),
          content: TextField(
            controller: _editTimeSlotController,
            decoration: InputDecoration(
              labelText: "Update Time Slot",
              hintText: 'e.g., 10:00 AM - 12:00 PM',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await updateTimeSlot(slotId, _editTimeSlotController.text);
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateTimeSlot(String slotId, String newSlot) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('provider')
          .doc(widget.providerId)
          .collection('timeSlots')
          .doc(slotId)
          .update({'slot': newSlot});
      Fluttertoast.showToast(msg: "Time slot updated successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update time slot: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }
}
