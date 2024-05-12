import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/util/AppColors.dart';
class ProfileScreenWidget extends StatefulWidget {
  Function backPress;

  ProfileScreenWidget({super.key, required  this.backPress});

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginprovider()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.backPress;
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
        ),
        backgroundColor: AppColors.background,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  child: Text('Customer Profile'),
                ),

              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                ElevatedButton(
                  onPressed: () => logout(context),
                  child: Text("Logout"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
