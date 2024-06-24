import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:servtol/categoriescustomer.dart';
import 'package:servtol/notificationcustomer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeCustomer extends StatefulWidget {
  const HomeCustomer({super.key});

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool useCloudImages = false; // Flag to switch between cloud and local images

  List<String> _localImages = [
    'assets/images/sofa1.webp',
    'assets/images/sofa2.jpeg',
    'assets/images/sofa3.jpg',
    'assets/images/sofa4.jpg',
  ];

  List<String> _cloudImages = [];

  @override
  void initState() {
    super.initState();
    if (useCloudImages) {
      fetchImages();
    }
  }

  fetchImages() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('carousel_images').get();
    setState(() {
      _cloudImages = snapshot.docs.map((doc) => doc['url'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> imagesToDisplay = useCloudImages ? _cloudImages : _localImages;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => customernotification()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            imagesToDisplay.isNotEmpty
                ? CarouselSlider(
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: imagesToDisplay.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: useCloudImages
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              }).toList(),
            )
                : Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Categoriescustomer(),
                            ),
                          );
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

                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              buildCategoryItem(Icons.code, 'Developer', Colors.blue),
                              SizedBox(width: 20),
                              buildCategoryItem(Icons.plumbing, 'Plumber', Colors.green),
                              SizedBox(width: 20),
                              buildCategoryItem(Icons.alternate_email, 'Social Media', Colors.orange),
                              SizedBox(width: 20),
                              buildCategoryItem(Icons.search, 'SEO', Colors.amber),
                              SizedBox(width: 20),
                              buildCategoryItem(Icons.document_scanner_rounded, 'Thesis', Colors.red),
                              SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   left: 0,
                      //   right: 0,
                      //   child: Container(
                      //     height: 2,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                      // Positioned(
                      //   bottom: 0,
                      //   left: 0,
                      //   right: 0,
                      //   child: IgnorePointer(
                      //     child: Container(
                      //       height: 30,
                      //       decoration: BoxDecoration(
                      //         gradient: LinearGradient(
                      //           colors: [
                      //             Colors.black.withOpacity(0.0),
                      //             Colors.white.withOpacity(0.5),
                      //             Colors.white,
                      //           ],
                      //           stops: [0.0, 0.5, 1.0],
                      //           begin: Alignment.centerLeft,
                      //           end: Alignment.centerRight,
                      //          ),),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
            ),
            )],
        ),
      ),
    );
  }

  Widget buildCategoryItem(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        // Handle the tap event
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}

