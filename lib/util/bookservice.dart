import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class BookServiceScreen extends StatefulWidget {
  final DocumentSnapshot service;

  const BookServiceScreen({Key? key, required this.service}) : super(key: key);

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int quantity = 1;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  TextEditingController descriptioncontroller= TextEditingController();
  // Correctly accessing price with explicit type casting
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  double get price {
    var data = widget.service.data()
        as Map<String, dynamic>?; // Ensure data is treated as a Map
    return (data?['Price'] ?? 26.00) as double; // Default value if not set
  }

  double tax = 5.30;

  double get subtotal => price * quantity;

  double get total => subtotal + tax;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      quantity = (quantity > 1) ? quantity - 1 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var serviceData =
        widget.service.data() as Map<String, dynamic>; // Explicit casting
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Service", style: TextStyle(
        color: AppColors.heading,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,)),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Services',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),

            Card(
              color: Colors.grey[850],
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(serviceData['ImageUrl'] ??
                      'https://example.com/default_image.jpg'),
                  backgroundColor: Colors.grey[300],
                  // child: Icon(Icons.broken_image, color: Colors.white),
                ),
                title: Text(serviceData['ServiceName'] ?? 'No Service Name',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(serviceData['Duration'] ?? 'No Duration',
                    style: TextStyle(color: Colors.grey[400])),
                trailing: Container(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.white),
                        onPressed: decrementQuantity,
                      ),
                      Text('$quantity',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: incrementQuantity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Description',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
             uihelper.customDescriptionField1(descriptioncontroller, "Enter Description"),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Booking Date & Time Slot',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
            Container(
              width: 200,
              height: 60,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () => _selectDate(context),
                child: Text(selectedDate == null
                    ? 'Select Date'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
              ),
            ),
            Container(
              width: 200,
              height: 60,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () => _selectTime(context),
                child: Text(selectedTime == null
                    ? 'Select Time'
                    : '${selectedTime!.format(context)}'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
