import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/providermain.dart';
import 'package:shimmer/main.dart';
class checkprovider extends StatefulWidget {
  checkprovider({super.key});

  @override
  State<checkprovider> createState() => _checkproviderState();
}

class _checkproviderState extends State<checkprovider> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProviderMainLayout(onBackPress: onBackPress)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginprovider()));
    }
  }

  void onBackPress() {
    // Define what should happen when the back button is pressed
    Navigator.of(context).pop();
  }
}
