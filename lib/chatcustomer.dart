import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
class chatcustomer extends StatefulWidget {
  Function onBackPress; // Making this final and required


   chatcustomer({super.key,required this.onBackPress});

  @override
  State<chatcustomer> createState() => _chatcustomerState();
}

class _chatcustomerState extends State<chatcustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 19,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 18, // Replace with the actual number of messages
              itemBuilder: (context, index) {
                // Replace this with your message widget
                return Center(
                  child: ListTile(
                    title: Center(child: Text('Message $index',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                        color: AppColors.black,
                      ),
                    ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                     hintText: 'Type a message...',
                      labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Handle send message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}