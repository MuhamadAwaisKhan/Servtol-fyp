import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:servtol/categoriescustomer.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            // Adding space from top
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
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
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
            SizedBox(height: 20),
            // Adding space between carousel and other content
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (context) => Categoriescustomer()));
                          // Replace this with your navigation logic
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // Handle the tap event for the first circle avatar
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.code, color: Colors.white),
                              ),
                              SizedBox(height: 5),
                              Text('Developer'),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            // Handle the tap event for the second circle avatar
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.green,
                              child: Icon(Icons.plumbing, color: Colors.white),

                              ),
                              SizedBox(height: 5),
                              Text('Plumber'),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            // Handle the tap event for the third circle avatar
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.orange,
                                child: Icon(Icons.alternate_email, color: Colors.white),
                              ),
                              SizedBox(height: 5),
                              Text('Social Media'),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            // Handle the tap event for the fourth circle avatar
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.amber,
                                child: Icon(Icons.search, color: Colors.white),
                              ),
                              SizedBox(height: 5),
                              Text('SEO '),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
