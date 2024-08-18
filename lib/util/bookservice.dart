import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

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

  double taxRate = 0.05; // Default tax rate of 5%

  double get price {
    var data = widget.service.data() as Map<String, dynamic>;
    return double.tryParse(data['Price'].toString()) ?? 26.00;
  }

  double get subtotal => price * quantity;

  double get tax => subtotal * taxRate;

  double get total => subtotal + tax;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTaxRate();
  }

  Future<void> fetchTaxRate() async {
    try {
      // Query the 'taxes' collection for a document with the name 'PriceTax'
      var querySnapshot = await FirebaseFirestore.instance
          .collection('taxes')
          .where('name', isEqualTo: 'PriceTax')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          taxRate = double.tryParse(
                  querySnapshot.docs.first.data()['rate'].toString()) ??
              0.05;
        });
      }
    } catch (e) {
      print('Error fetching tax rate: $e');
    }
  }

  void decrementQuantity() {
    setState(() {
      quantity = (quantity > 1) ? quantity - 1 : 1;
    });
  }

  Future<void> saveBooking() async {
    if (selectedDate == null ||
        selectedTime == null ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var user = FirebaseAuth.instance.currentUser;
      var currentUserId = user?.uid ??
          'no-user-id'; // Fallback to 'no-user-id' if not logged in

      var serviceData = widget.service.data() as Map<String, dynamic>;
      var customerId = serviceData.containsKey('customerId')
          ? serviceData['customerId']
          : currentUserId;

      var bookingId =
          FirebaseFirestore.instance.collection('bookings').doc().id;
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set({
        'serviceId': widget.service.id,
        'customerId': customerId,
        // Using either the document's customerId or the current user's ID
        'providerId': widget.service['providerId'],
        'date': selectedDate?.toIso8601String(),
        'time': selectedTime?.format(context),
        'quantity': quantity,
        'description': descriptionController.text,
        'total': total,
        'bookingId': bookingId,
      });
      print("Booking saved successfully.");
      Navigator.of(context).pop();
    } catch (e) {
      print("Error saving booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to book service: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var serviceData = widget.service.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Book Service"),
      ),
      body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Services',
              style: TextStyle(color: Colors.black, fontSize: 20)),
        ),
        if (isLoading) LinearProgressIndicator(),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Text('Service Details', style: TextStyle(
        //       fontSize: 24, fontWeight: FontWeight.bold)),
        // ),
        // ListTile(
        //   title: Text(serviceData['ServiceName'] ?? 'No Service Name'),
        //   subtitle: Text('Duration: ${serviceData['Duration']}'),
        //   trailing: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       IconButton(
        //           icon: Icon(Icons.remove), onPressed: decrementQuantity),
        //       Text('$quantity'),
        //       IconButton(
        //           icon: Icon(Icons.add), onPressed: incrementQuantity),
        //     ],
        //   ),
        // ),
        Card(
          color: Colors.grey[850],
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: FadeInImage.assetNetwork(
              placeholder: 'assets/placeholder.png',
              // Local asset placeholder image
              image: serviceData['ImageUrl'] ??
                  'https://example.com/default_image.jpg',
              fit: BoxFit.cover,
              width: 48,
              height: 48,
              imageErrorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, color: Colors.white);
              },
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
          child: Text('Description ',
              style: TextStyle(color: Colors.black, fontSize: 20)),
        ),

        uihelper.customDescriptionField1(
            descriptionController, "Enter Description"),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Booking Date & Slot ',
              style: TextStyle(color: Colors.black, fontSize: 20)),
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
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apply Coupon',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.local_offer, color: Colors.white),
                label: Text('Apply', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  // Handle coupon application
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurpleAccent)),
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price Details',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Price'),
                    Text('\$${price.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal'),
                    Text('\$${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tax (${(taxRate * 100).toStringAsFixed(0)}%)'),
                    Text('\$${tax.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              saveBooking();
            },
            child: Text('Confirm Booking'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple,
            ),
          ),
        )
      ])),
    );
  }
}
