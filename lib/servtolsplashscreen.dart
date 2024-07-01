import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/main%20login.dart';
import 'package:servtol/startscreen.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ServToolSplashScreen extends StatefulWidget {
  const ServToolSplashScreen({super.key});

  @override
  State<ServToolSplashScreen> createState() => _ServToolSplashScreenState();
}

class _ServToolSplashScreenState extends State<ServToolSplashScreen> {
  int _currentIndex = 0;
  final CarouselController _controller = CarouselController();

  List<Widget> _buildScreens() {
    return [
      _buildScreen(
        title: 'Explore Our Services',
        description:
        'Discover a wide range of services tailored to meet your needs.',
        color: Color(0xFF005F73), // A deep teal background
        animation: 'assets/images/exploringservices.json',
      ),
      _buildScreen(
        title: 'Track Your Services',
        description:
        'Stay updated with real-time progress on all your service requests.',
        color: Color(0xFF0A9396), // A soft cyan
        animation: 'assets/images/trackservice.json',
      ),
      _buildScreen(
        title: 'Custom Recommendations',
        description:
        'Get suggestions and tips uniquely tailored to your preferences and past choices.',
        color: Color(0xFF94D2BD), // A light teal
        animation: 'assets/images/recom.json',
      ),
    ];
  }

  Widget _buildScreen({required String title,
    required String description,
    required Color color,
    required String animation}) {
    // Determine text color based on background brightness
    bool isDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    Color textColor =
    isDark ? Colors.white : Colors.black; // High contrast text color
    Color iconColor =
    isDark ? Colors.white : Colors.teal; // High contrast icon color

    return Container(
      color: color,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(animation, height: 200),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
            items: _buildScreens(),
            carouselController: _controller,
            options: CarouselOptions(
              height: double.infinity,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => mainlogin()));
              },
              child: Text('Skip', style: TextStyle(fontFamily: 'Poppins',
                  color: Colors.white)),
              // Consistent high contrast text
              style: TextButton.styleFrom(
                 backgroundColor: Colors.amber, // Clear background or use theme color with opacity
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                if (_currentIndex == 2) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => mainlogin()));
                } else {
                  _controller.nextPage();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue, // Attractive and consistent with theme
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  _currentIndex == 2 ? Icons.check : Icons.arrow_forward,
                  color: Colors.white, // High contrast
                ),
              ),
            ),
          ),
          Positioned(
            top: 650,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: 3,
                effect: ExpandingDotsEffect(
                  dotHeight: 8.0,
                  dotWidth: 8.0,
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey,
                  // Sufficient contrast
                  expansionFactor: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
