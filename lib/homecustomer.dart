import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class homecustomer extends StatefulWidget {
  const homecustomer({super.key});

  @override
  State<homecustomer> createState() => _homecustomerState();
}

class _homecustomerState extends State<homecustomer> {
  final PageController _pageController = PageController();
int _currentIndex = 0;

final List<String> _images = [
  'assets/images/sofa1.webp',
  'assets/images/sofa2.jpeg',
  'assets/images/sofa3.jpg',
  'assets/images/sofa4.jpg',

];

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // title: Text('Home'),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              height: 250.0,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: _images.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    // margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            }).toList(),
          ),
          // SizedBox(height: 10),
          // SmoothPageIndicator(
          //   controller: _pageController, // Use _pageController here
          //   count: _images.length,
          //   effect: ExpandingDotsEffect(
          //     dotWidth: 10,
          //     dotHeight: 8,
          //     dotColor: Colors.grey,
          //     activeDotColor: Colors.blue,
          //   ),
          // ),
        ],

      ),
    ),
  );
}
}