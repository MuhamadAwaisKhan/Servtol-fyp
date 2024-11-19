import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class FeedbackScreen extends StatefulWidget {
  final String bookingId;
  const FeedbackScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedEmojiIndex = -1; // To track the selected emoji

  Map<String, int> _feedback = {
    'Ease of booking': 0,
    'Service quality': 0,
    'Value for Money': 0,
    'Timing & Punctuality': 0,
    'Provider Behaviour': 0,
    'Communication': 0,
    'Overall Satisfaction': 0, // Add a key to store the emoji rating
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
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  void _fetchBookingDetails() async {
    try {
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (bookingSnapshot.exists) {
        // Pre-fill fields with booking data
        // Example:
        // _serviceNameController.text = bookingSnapshot['serviceName'];
        // ... (add more fields as needed)
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      // Handle error (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading booking details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Text(
          'How was the Service?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
          ),
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
              SizedBox(height: 20),

              // Emoji selection below the star rating
              Column(
                children: [
                  Text(
                    'How do you feel about the experience?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
                    ),
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
                                  color: emojiColors[
                                  index], // Set color based on the emoji
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
      uihelper.CustomButton1(() async {
        // Store the emoji rating in the _feedback map
        // if (_selectedEmojiIndex >= 0) {
        //   _feedback['Overall Feeling'] = _selectedEmojiIndex + 1;
        // }

        // Basic validation
        if (_selectedEmojiIndex == -1 &&
            _feedback.values.every((value) => value == 0) &&
            _notesController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please provide some feedback.')),
          );
          return;
        }

        try {
          // Check if a review for this booking already exists
          QuerySnapshot existingReview = await FirebaseFirestore.instance
              .collection('reviews')
              .where('bookingId', isEqualTo: widget.bookingId)
              .get();

          if (existingReview.docs.isNotEmpty) {
            // A review already exists, ask the user if they want to update it
            bool? updateReview = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Review Exists'),
                  content: Text(
                      'You have already submitted a review for this booking. Do you want to update it?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text('Update'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );

            if (updateReview != true) {
              return;
            } else {
              // Update the existing review document
              String existingReviewId = existingReview.docs.first.id;

              await FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(existingReviewId)
                  .update({
                'emojiRating': _selectedEmojiIndex + 1,
                'feedback': _feedback,
                'notes': _notesController.text,
              });

              // Show success dialog and navigate back
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Thank You!', style: TextStyle(fontFamily: 'Poppins')),
                    content: Text('Your review has been updated!', style: TextStyle(fontFamily: 'Poppins')),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK', style: TextStyle(fontFamily: 'Poppins')),
                        onPressed: () {
                          Navigator.of(context)
                            ..pop()
                            ..pop()
                            ..pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            // No existing review, add a new one
            DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
                .collection('bookings')
                .doc(widget.bookingId)
                .get();

            // Extract serviceId, customerId, and providerId from the booking document
            String serviceId = bookingSnapshot.get('serviceId');
            String customerId = bookingSnapshot.get('customerId');
            String providerId = bookingSnapshot.get('providerId');

            // Add a new document to the 'reviews' collection
            await FirebaseFirestore.instance.collection('reviews').add({
              'bookingId': widget.bookingId,
              'serviceId': serviceId,
              'customerId': customerId,
              'providerId': providerId,
              'emojiRating': _selectedEmojiIndex + 1,
              'feedback': _feedback,
              'notes': _notesController.text,
              // ... other review data ...
            });

            // Show success dialog and navigate back
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Thank You!', style: TextStyle(fontFamily: 'Poppins')),
                  content: Text('Thanks for the feedback!', style: TextStyle(fontFamily: 'Poppins')),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK', style: TextStyle(fontFamily: 'Poppins')),
                      onPressed: () {
                        Navigator.of(context)
                          ..pop()
                          ..pop()
                          ..pop(); // Close the dialog and go back to previous screens
                      },
                    ),
                  ],
                );
              },
            );
          }
        } catch (e) {
          print('Error submitting feedback: $e');
          // Handle error (e.g., show an error message)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit feedback.')),
          );
        }
      }, "Submit", 50, 170),

      ],
          ),
        ),
      ),
    );
  }
}