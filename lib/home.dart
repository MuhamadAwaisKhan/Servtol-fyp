import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/logincustomer.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => logincustomer()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => logout(context),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}