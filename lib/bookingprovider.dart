import 'package:flutter/material.dart';
class BookingScreenWidget extends StatefulWidget {
  BookingScreenWidget({super.key, required this.backPress});

  Function backPress;
  @override
  State<BookingScreenWidget> createState() => _BookingScreenWidgetState();
}

class _BookingScreenWidgetState extends State<BookingScreenWidget> {
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.backPress.call();
        return Future(() => false);
      },
      child: Container(
        child: Text('Booking Screen'),
      ),
    );
  }
}