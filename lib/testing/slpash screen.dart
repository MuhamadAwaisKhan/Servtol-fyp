import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentIndex = 0;
  final CarouselController _controller = CarouselController();

  List<Widget> _buildScreens() {
    return [
      _buildScreen(
        title: 'Welcome to MySkincare',
        description: 'Your journey to better skin starts here!',
        color: Colors.blue,
        image: 'assets/images/sofa4.jpg',
      ),
      _buildScreen(
        title: 'Track Your Progress',
        description: 'See how your skin improves over time.',
        color: Colors.green,
        image: 'assets/images/sofa4.jpg',
      ),
      _buildScreen(
        title: 'Get Personalized Tips',
        description: 'Receive tips tailored to your skin type.',
        color: Colors.purple,
        image: 'assets/images/sofa4.jpg',
      ),
    ];
  }

  Widget _buildScreen({required String title, required String description, required Color color, required String image}) {
    return Container(
      color: color,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image, height: 200),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
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
                // Skip button action
              },
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                if (_currentIndex == 2) {
                  // Next button action when on the last screen
                } else {
                  _controller.nextPage();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  _currentIndex == 2 ? Icons.check : Icons.arrow_forward,
                  color: Colors.blue, // Customize the color as needed
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
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
                  expansionFactor: 3, // How much the dot expands
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}