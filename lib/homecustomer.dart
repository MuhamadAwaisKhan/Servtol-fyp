import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/categoriescustomer.dart';
import 'package:servtol/searchcustomer.dart';
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
  CarouselSliderController _carouselController = CarouselSliderController();
  List<Map<String, dynamic>> _cloudImages = [];

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  void fetchImages() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('service').get();
    setState(() {
      _cloudImages = snapshot.docs
          .map((doc) => {'url': doc['ImageUrl'], 'id': doc.id})
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading)),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => customernotification())),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => searchcustomer())),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_cloudImages.isNotEmpty)
              servicesCarousel(),
            const SizedBox(height: 20),
            AnimatedSmoothIndicator(
              activeIndex: _current,
              count: _cloudImages.length,
              effect: ExpandingDotsEffect(dotWidth: 10,
                  dotHeight: 10,
                  dotColor: Colors.grey,
                  activeDotColor: Colors.blueAccent),
              onDotClicked: (index) => _carouselController.animateToPage(index),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: buildCategoriesHeader(),
            ),
            buildHorizontalCategoryList(),
            servicesList(),
          ],
        ),
      ),
    );
  }

  Widget servicesCarousel() {
    return CarouselSlider(
      items: _cloudImages.map((item) =>
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(item['url']),
                  fit: BoxFit.cover,
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
    );
  }

  Widget buildCategoriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CategoriesCustomer())),
          child: const Text(
              'View All', style: TextStyle(color: Colors.blue, fontSize: 16)),
        ),
      ],
    );
  }

  Widget buildHorizontalCategoryList() {
    List<Map<String, dynamic>> categories = [
      {'icon': Icons.code, 'label': 'Developer', 'color': Colors.blue},
      {'icon': Icons.plumbing, 'label': 'Plumber', 'color': Colors.green},
      {
        'icon': Icons.alternate_email,
        'label': 'Social Media',
        'color': Colors.orange
      },
      {'icon': Icons.pets, 'label': 'Pet Care', 'color': Colors.deepPurple},
      {'icon': Icons.brush, 'label': 'Art & Design', 'color': Colors.pink},
      {'icon': Icons.build, 'label': 'DIY', 'color': Colors.brown},
      {'icon': Icons.directions_bike, 'label': 'Cycling', 'color': Colors.red},
      {'icon': Icons.kitchen, 'label': 'Cooking', 'color': Colors.teal},
      {'icon': Icons.fitness_center, 'label': 'Fitness', 'color': Colors.black},
      {'icon': Icons.music_note, 'label': 'Music', 'color': Colors.cyan},
      {'icon': Icons.local_florist, 'label': 'Gardening', 'color': Colors.lime},
      {'icon': Icons.camera_alt, 'label': 'Photography', 'color': Colors.amber},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) =>
            buildCategoryItem(
              category['icon'], category['label'], category['color'],
                  () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CategoriesCustomer())),
            )).toList(),
      ),
    );
  }

  Widget buildCategoryItem(IconData icon, String label, Color color,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(radius: 20,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white)),
            const SizedBox(height: 5),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget servicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Services",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                  fontSize: 18,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigation to a screen that lists all services
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('service').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("No Data Available");
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot serviceDoc = snapshot.data!.docs[index];
                  return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('provider')
                          .doc(serviceDoc['providerId'])
                          .get(),
                      builder: (context, providerSnapshot) {
                        if (!providerSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return buildServiceCard(
                            context, serviceDoc, providerSnapshot.data!);
                      }
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  Widget buildServiceCard(BuildContext context, DocumentSnapshot serviceDoc, DocumentSnapshot providerDoc) {
    // Assuming fields are correctly retrieved.
    String imageUrl = getDocumentField(serviceDoc, 'ImageUrl', 'default_image_url');
    String serviceName = getDocumentField(serviceDoc, 'ServiceName', 'No service name');
    String subcategory = getDocumentField(serviceDoc, 'Subcategory', 'General');
    String servicePrice = getDocumentField(serviceDoc, 'Price', 'Call for price');
    String providerPic = getDocumentField(providerDoc, 'ProfilePic', 'default_profile_pic_url');
    String providerName = getDocumentField(providerDoc, 'FirstName', 'No provider name');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Servicecustomerdetail(service:serviceDoc),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shadowColor: Colors.deepPurple[200],
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple[800]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subcategory,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(providerPic),
                    radius: 15,
                  ),
                  Text(
                    providerName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "\$" + servicePrice,
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic getDocumentField(DocumentSnapshot doc, String fieldName, [dynamic defaultValue = '']) {
    var data = doc.data() as Map<String, dynamic>?;
    return data != null && data.containsKey(fieldName) ? data[fieldName] : defaultValue;
  }



}