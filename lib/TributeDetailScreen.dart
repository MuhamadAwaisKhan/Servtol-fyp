import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:servtol/util/AppColors.dart'; // Make sure this path is correct
import 'package:translator/translator.dart';

class TributeDetailScreen extends StatefulWidget {
  final String name;
  final String occupation;
  final String details;
  final String pictureUrl;

  TributeDetailScreen({
    required this.name,
    required this.occupation,
    required this.details,
    required this.pictureUrl,
  });

  @override
  State<TributeDetailScreen> createState() => _TributeDetailScreenState();
}

class _TributeDetailScreenState extends State<TributeDetailScreen> {
  final translator = GoogleTranslator();
  String? translatedText;
  String targetLanguage = 'ur'; // Default to Spanish

  Future<void> _translateText() async {
    try {
      var translation =
          await translator.translate(widget.details, to: targetLanguage);
      setState(() {
        translatedText = translation.text;
      });
    } catch (e) {
      print('Error translating: $e');
      // Handle translation errors (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Translation failed.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tribute Details',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Picture and Name
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Container(
                      child: Image.network(widget.pictureUrl),
                    ),
                  ),
                );
              },
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: NetworkImage(widget.pictureUrl),
                            backgroundColor: Colors.grey[200],
                          ),
                          SizedBox(height: 20),
                          Text(
                            widget.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.occupation,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Details Section (updated)
            Text(
              'Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.details,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 10),
                    if (translatedText != null)
                      Text(
                        translatedText!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.green[800],
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Translator Button
            Center(
              child: ElevatedButton(
                onPressed: _translateText,
                child: Text('Translate Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Footer Section (Back button)
            // Center(
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       Navigator.pop(context); // Navigate back
            //     },
            //     icon: Icon(Icons.arrow_back),
            //     label: Text('Back to Tributes',style: TextStyle(fontFamily: 'Poppins'),),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.blueAccent,
            //       foregroundColor: Colors.white,
            //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            //       textStyle: GoogleFonts.poppins(
            //         fontSize: 16,
            //
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
