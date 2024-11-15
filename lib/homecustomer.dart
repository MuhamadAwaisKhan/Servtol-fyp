import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/Categorybyservices.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/allservicescustomers.dart';
import 'package:servtol/categoriescustomer.dart';
import 'package:servtol/searchcustomer.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:servtol/notificationcustomer.dart';
import 'package:rxdart/rxdart.dart';

class HomeCustomer extends StatefulWidget {
  final Function onBackPress;

  HomeCustomer({super.key, required this.onBackPress});

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int _current = 0;
  CarouselSliderController _carouselController = CarouselSliderController();
  List<Map<String, dynamic>> _cloudImages = [];
  List<String> categories = [];

  // Mapping category names to Font Awesome icons
  Map<String, IconData> categoryIcons = {
    'Healthcare': FontAwesomeIcons.medkit,
    'Design & Multimedia': FontAwesomeIcons.paintBrush,
    'Telemedicine': FontAwesomeIcons.headset,
    'Education': FontAwesomeIcons.graduationCap,
    'Retail': FontAwesomeIcons.shoppingCart,
  };

  @override
  void initState() {
    super.initState();
    fetchImages();
    _fetchCategories();
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

  Future<void> _fetchCategories() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference categoriesRef = firestore.collection('Category');
    try {
      QuerySnapshot snapshot = await categoriesRef.get();
      List<String> fetchedCategories = snapshot.docs.map((doc) {
        return doc['Name'] as String;
      }).toList();

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  int unreadCount = 0;

  void listenForUnreadNotifications() {
    FirebaseFirestore.instance
        .collection('bookingnotifications')
        .where('customerId', isEqualTo: currentUser?.uid)
        .where('isRead1', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      int notificationUnreadCount = snapshot.docs.length;

      FirebaseFirestore.instance
          .collection('paymentnotification')
          .where('customerId', isEqualTo: currentUser?.uid)
          .where('isRead1', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        int paymentNotificationUnreadCount = snapshot.docs.length;

        setState(() {
          unreadCount = notificationUnreadCount + paymentNotificationUnreadCount;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.heading)),
        backgroundColor: AppColors.background,
        leading: Icon(size: 0.0, Icons.arrow_back),
        actions: [
          StreamBuilder<List<QuerySnapshot>>(
            stream: CombineLatestStream.list([
              FirebaseFirestore.instance
                  .collection('bookingnotifications')
                  .where('customerId', isEqualTo: currentUser?.uid)
                  .where('isRead1', isEqualTo: false)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              FirebaseFirestore.instance
                  .collection('paymentnotification')
                  .where('customerId', isEqualTo: currentUser?.uid)
                  .where('isRead1', isEqualTo: false)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
            ]),
            builder: (context, snapshot) {
              int unreadCount = 0;

              if (snapshot.hasData) {
                unreadCount = snapshot.data![0].docs.length + snapshot.data![1].docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    iconSize: 30,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    icon: FaIcon(FontAwesomeIcons.bell),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => customernotification(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            onPressed: () =>
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchScreen())),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
          child: Column(children: [
            if (_cloudImages.isNotEmpty) ...[
              servicesCarousel(),
              const SizedBox(height: 20),
              AnimatedSmoothIndicator(
                activeIndex: _current,
                count: _cloudImages.length,
                effect: ExpandingDotsEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    dotColor: Colors.grey,
                    activeDotColor: Colors.blueAccent),
                onDotClicked: (index) =>
                    _carouselController.animateToPage(index),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: buildCategoriesHeader(),
            ),
            buildHorizontalCategoryList(),
            servicesList(),
          ])),
    );
  }

  Widget servicesCarousel() {
    return CarouselSlider(
      items: _cloudImages
          .map((item) =>
          GestureDetector(
            onTap: () {
              DocumentSnapshot serviceSnapshot;
              FirebaseFirestore.instance
                  .collection('service')
                  .doc(item['id'])
                  .get()
                  .then((doc) {
                if (doc.exists) {
                  serviceSnapshot = doc;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Servicecustomerdetail(service: serviceSnapshot),
                      ));
                } else {
                  print("Document does not exist.");
                }
              });
            },
            child: ClipRRect(
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
            ),
          ))
          .toList(),
      options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 2.0,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
      carouselController: _carouselController,
    );
  }
  Widget buildCategoriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Categories',
            style: TextStyle(
                fontSize: 17,
                color: AppColors.heading,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () =>
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CategoriesCustomer(
                            onBackPress: widget.onBackPress,
                          ))),
          child: const Text('View All',
              style: TextStyle(
                  color: AppColors.customButton,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget buildHorizontalCategoryList() {
    return categories.isEmpty
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length > 5 ? 5 : categories.length, // Show only up to 5 items
        itemBuilder: (context, index) {
          String categoryName = categories[index];
          IconData categoryIcon = categoryIcons[categoryName] ?? FontAwesomeIcons.questionCircle;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryServicesScreen(categoryName: categoryName),
                  ),
                );
                // print('Tapped on $categoryName');
              },
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(categoryIcon, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(categoryName,
                      style: const TextStyle(
                          color: AppColors.heading,
                          fontFamily: 'Poppins',
                          fontSize: 10,)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget servicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Services",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                  fontSize: 17,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServicesScreen(), // Pass the DocumentSnapshot here
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: AppColors.customButton,
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
            stream: FirebaseFirestore.instance.collection('service')
                .orderBy("ServiceName",descending: false)

                .snapshots(),
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
                // Limit the displayed items to six
                itemCount: min(snapshot.data!.docs.length, 6),
                itemBuilder: (context, index) {
                  DocumentSnapshot serviceDoc = snapshot.data!.docs[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('provider')
                        .doc(serviceDoc['providerId'])
                        .get(),
                    builder: (context, providerSnapshot) {
                      if (!providerSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        );
                      }
                      return buildServiceCard(context, serviceDoc, providerSnapshot.data!);
                    },
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
            builder: (context) => Servicecustomerdetail(service: serviceDoc),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shadowColor: Colors.blue[200],
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
                  Row(
                    children: [
                      Text(
                        serviceName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue[800]),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "\$" + servicePrice,
                        style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    subcategory,
                    style: TextStyle(fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(providerPic),
                    radius: 15,
                  ),
                  SizedBox(width: 20),
                  Text(
                    providerName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
