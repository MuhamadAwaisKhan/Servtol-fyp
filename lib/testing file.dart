
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _textFieldController = TextEditingController();
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Number Input'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _phoneNumber = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Clear the existing text field focus
                    FocusScope.of(context).unfocus();

                    // Navigate to the phone input widget
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhoneNumberInputPage(),
                      ),
                    ).then((phoneNumber) {
                      if (phoneNumber != null) {
                        setState(() {
                          _textFieldController.text = phoneNumber;
                          _phoneNumber = phoneNumber;
                        });
                      }
                    });
                  },
                  child: Text('Select from List'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Phone Number: $_phoneNumber',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneNumberInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Phone Number'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Phone Number',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  Navigator.pop(context, number.phoneNumber);
                },
                inputDecoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
