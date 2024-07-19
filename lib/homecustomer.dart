import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:servtol/categoriescustomer.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:servtol/notificationcustomer.dart';

class HomeCustomer extends StatefulWidget {
  const HomeCustomer({Key? key}) : super(key: key);

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  int _current = 0;
  CarouselController _carouselController = CarouselController();
  List<Map<String, dynamic>> _cloudImages = [];
  List<Map<String, dynamic>> categories = [
    {'icon': Icons.code, 'label': 'Developer', 'color': Colors.blue},
    {'icon': Icons.plumbing, 'label': 'Plumber', 'color': Colors.green},
    {'icon': Icons.alternate_email, 'label': 'Social Media', 'color': Colors.orange},
    {'icon': Icons.pets, 'label': 'Pet Care', 'color': Colors.deepPurple},
    {'icon': Icons.brush, 'label': 'Art & Design', 'color': Colors.pink},
    {'icon': Icons.build, 'label': 'DIY', 'color': Colors.brown},
    {'icon': Icons.directions_bike, 'label': 'Cycling', 'color': Colors.red},
    {'icon': Icons.kitchen, 'label': 'Cooking', 'color': Colors.teal},
    {'icon': Icons.fitness_center, 'label': 'Fitness', 'color': Colors.black},
    {'icon': Icons.music_note, 'label': 'Music', 'color': Colors.cyan},
    {'icon': Icons.local_florist, 'label': 'Gardening', 'color': Colors.lime},
    {'icon': Icons.camera_alt, 'label': 'Photography', 'color': Colors.amber},
    // Add more categories as needed
  ];

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  void fetchImages() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('service').get();
    setState(() {
      _cloudImages = snapshot.docs.map((doc) => {
        'url': doc['ImageUrl'],
        'id': doc.id  // Assuming each doc has a unique ID used to fetch details
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Home",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => customernotification())),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => customernotification())),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_cloudImages.isNotEmpty)
              CarouselSlider(
                items: _cloudImages.map((item) => GestureDetector(
                  // onTap: ()
                  // => Navigator.push(context, MaterialPageRoute(
                  //   builder: (context) => ServiceDetailScreen(serviceId: item['id']),
                  // ),



                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(item['url']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )).toList(),
                options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 2.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }
                ),
                carouselController: _carouselController,
              ),
            SizedBox(height: 20),
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _current,
                count: _cloudImages.length,
                effect: ExpandingDotsEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  dotColor: Colors.grey,
                  activeDotColor: Colors.blueAccent,
                ),
                onDotClicked: (index) {
                  _carouselController.animateToPage(index);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: buildCategoriesHeader(),
            ),
            buildHorizontalCategoryList(),
          ],
        ),
      ),
    );
  }

  Widget buildCategoriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesCustomer())),
          child: Text('View All', style: TextStyle(color: Colors.blue, fontSize: 16)),
        ),
      ],
    );
  }

  Widget buildHorizontalCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) => buildCategoryItem(
          category['icon'],
          category['label'],
          category['color'],
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => customernotification())),  // Navigate to a generic categories detail view
        )).toList(),
      ),
    );
  }

  Widget buildCategoryItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(radius: 20, backgroundColor: color, child: Icon(icon, color: Colors.white)),
            SizedBox(height: 5),
            Text(label),
          ],
        ),
      ),
    );
  }
}
