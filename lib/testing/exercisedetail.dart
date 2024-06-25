import 'package:flutter/material.dart';
import 'package:servtol/testing/list.dart';

class ExerciseDetail extends StatefulWidget {
  final Listmodel exercise;

  ExerciseDetail({super.key, required this.exercise});

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Detail'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(
              widget.exercise.imageurl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/startlogo.jpeg');
              },
            ),
            SizedBox(height: 16.0),
            Text(
              widget.exercise.name,
              style: TextStyle(
                fontFamily: "Poppins",
                color: Colors.lightBlue,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.exercise.description,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
