import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FeedbackScreen(),
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _textController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Text Input for Feedback
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Star Rating
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Here you can process the feedback
                String feedbackText = _textController.text;
                double rating = _rating;
                print('Feedback: $feedbackText');
                print('Rating: $rating');
                // TODO: Send feedback to your server or perform other actions
                // You can show a snackbar or dialog to confirm submission
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feedback submitted! (Rating: $rating)')),
                );
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';


// class FeedbackAndReview extends StatefulWidget {
//   @override
//   _FeedbackAndReviewState createState() => _FeedbackAndReviewState();
// }
//
// class _FeedbackAndReviewState extends State<FeedbackAndReview> {
//   int _rating = 0; // Holds the star rating (1-5)
//   final TextEditingController _feedbackController = TextEditingController();
//
//   void _setRating(int rating) {
//     setState(() {
//       _rating = rating;
//     });
//   }
//
//   @override
//   void dispose() {
//     _feedbackController.dispose(); // Dispose the controller to avoid memory leaks
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Feedback & Review'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'How was your experience?',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: List.generate(5, (index) {
//                 return IconButton(
//                   onPressed: () {
//                     _setRating(index + 1);
//                   },
//                   icon: Icon(
//                     index < _rating ? Icons.star : Icons.star_border,
//                     color: Colors.amber,
//                     size: 40,
//                   ),
//                 );
//               }),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _feedbackController,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 labelText: 'Your feedback',
//                 border: OutlineInputBorder(),
//                 hintText: 'Please share your experience',
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_rating == 0) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Please provide a star rating')),
//                     );
//                   } else {
//                     // Handle submission of feedback and rating
//                     String feedback = _feedbackController.text;
//                     print('Rating: $_rating');
//                     print('Feedback: $feedback');
//                     // You can now send the feedback and rating to your backend or Firestore
//
//                     // Show confirmation to user
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Thank you for your feedback!')),
//                     );
//                   }
//                 },
//                 child: Text('Submit'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
