import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  int _selectedEmojiIndex = -1; // To track the selected emoji

  Map<String, int> _feedback = {
    'Ease of booking': 0,
    'Service quality': 0,
    'Cleanliness of the bus': 0,
    'Timing & Punctuality': 0,
    'Provider Behaviour': 0,
  };

  final _notesController = TextEditingController();

  // Emoji set and labels
  List<String> emojis = ['😡', '😐', '☹️', '😊', '😍'];
  List<String> emojiLabels = ['Angry', 'Neutral', 'Sad', 'Good', 'Love'];

// Define colors that relate to each emoji
  List<Color> emojiColors = [
    Colors.red, // Angry
    Colors.orange, // Neutral
    Colors.amber, // Sad
    Colors.blue, // Good
    Colors.pinkAccent // Love
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'How was the Service?',
          style: TextStyle(fontFamily: 'Poppins',fontSize: 17,fontWeight: FontWeight.bold,
          color: AppColors.heading,),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context)..pop()..pop(),
          ),
        ],
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(size: 40,
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),

              // Emoji selection below the star rating
              Column(
                children: [
                  Text(
                    'How do you feel about the experience?',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16,fontWeight: FontWeight.bold,color: AppColors.heading),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(emojis.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEmojiIndex = index;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              emojis[index],
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'Poppins',
                                color: _selectedEmojiIndex == index
                                    ? emojiColors[index]
                                    : Colors.black,
                              ),
                            ),
                            if (_selectedEmojiIndex == index)
                              Text(
                                emojiLabels[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: emojiColors[index], // Set color based on the emoji
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Feedback options with thumbs up/down
              ..._feedback.keys.map((option) {
                return Row(
                  children: [
                    Text(
                      option,
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _feedback[option] = 1;
                        });
                      },
                      icon: Icon(
                        _feedback[option] == 1
                            ? Icons.thumb_up
                            : Icons.thumb_up_off_alt,
                        color:
                            _feedback[option] == 1 ? Colors.green : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _feedback[option] = -1;
                        });
                      },
                      icon: Icon(
                        _feedback[option] == -1
                            ? Icons.thumb_down
                            : Icons.thumb_down_off_alt,
                        color:
                            _feedback[option] == -1 ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
              SizedBox(height: 20),

              // Add a note
              uihelper.customDescriptionField1(_notesController, "Review"),
              SizedBox(height: 20),

              // Submit button
              uihelper.CustomButton1(() {
                // TODO: Handle feedback submission
                print('Rating: $_rating');
                print(
                    'Selected Emoji: ${_selectedEmojiIndex >= 0 ? emojiLabels[_selectedEmojiIndex] : 'None'}');
                print('Feedback: $_feedback');
                print('Notes: ${_notesController.text}');
                // // Show Snackbar
                // Fluttertoast.showToast(
                //   msg: "Thanks for the feedback!",
                //   toastLength: Toast.LENGTH_SHORT,
                //   gravity: ToastGravity.BOTTOM,
                //   backgroundColor: Colors.green,
                //   textColor: Colors.white,
                //   fontSize: 16.0,
                // );


                //   SnackBar(
                //     content: Text(
                //       'Thanks for the feedback!',
                //       style: TextStyle(fontFamily: 'Poppins'),
                //     ),
                //     backgroundColor: Colors.green,
                //     duration: Duration(seconds: 2),
                //   ),
                // );
                showDialog(
                    context: context,
                    builder: (BuildContext context)
                {
                  return AlertDialog(
                    title: Text(
                        'Thank You!', style: TextStyle(fontFamily: 'Poppins')),
                    content: Text(
                      'Thanks for the feedback!',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK', style: TextStyle(
                            fontFamily: 'Poppins')),
                        onPressed: () {
                          Navigator.of(context)..pop()..pop()..pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
                );
              }, "Submit", 50, 170),
            ],
          ),
        ),
      ),
    );
  }
}
