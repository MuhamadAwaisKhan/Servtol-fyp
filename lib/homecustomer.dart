import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/Servicecustomerdetail.dart';
import 'package:servtol/categoriescustomer.dart';
import 'package:servtol/searchcustomer.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:servtol/notificationcustomer.dart';
import 'package:rxdart/rxdart.dart';

class HomeCustomer extends StatefulWidget {
  Function onBackPress; // Making this final and required

  HomeCustomer({super.key, required this.onBackPress});

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Initial loading text
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

  int unreadCount = 0;

  // Function to listen for unread notifications
  void listenForUnreadNotifications() {
    // Listen to notifications collection
    FirebaseFirestore.instance
        .collection('bookingnotifications')
        .where('customerId', isEqualTo: currentUser?.uid)
        .where('isRead1', isEqualTo: false)
        .orderBy('timestamp', descending: true) // Add orderBy clause
        .snapshots()
        .listen((snapshot) {
      // Update unread count for notifications
      int notificationUnreadCount = snapshot.docs.length;

      // Listen to paymentnotification collection
      FirebaseFirestore.instance
          .collection('paymentnotification')
          .where('customerId', isEqualTo: currentUser?.uid)
          .where('isRead1', isEqualTo: false)
          .orderBy('timestamp', descending: true) // Add orderBy clause
          .snapshots()
          .listen((snapshot) {
        // Update unread count for payment notifications
        int paymentNotificationUnreadCount = snapshot.docs.length;

        // Combine unread counts and update state
        setState(() {
          unreadCount =
              notificationUnreadCount + paymentNotificationUnreadCount;
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
                  .collection('notifications')
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
              FirebaseFirestore.instance
                  .collection('notification_review')
                  .where('customerId', isEqualTo: currentUser?.uid)
                  .where('isRead1', isEqualTo: false)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
            ]),
            builder: (context, snapshot) {
              int unreadCount = 0;

              if (snapshot.hasData) {
                // Combine unread counts from all three collections
                unreadCount = snapshot.data![0].docs.length + // notifications
                    snapshot.data![1].docs.length + // payment notifications
                    snapshot.data![2].docs.length;  // review notifications
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => searchcustomer())),
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
            onDotClicked: (index) => _carouselController.animateToPage(index),
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
          .map((item) => GestureDetector(
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
                    width: MediaQuery.of(context).size.width,
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
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CategoriesCustomer(
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
        children: categories
            .map((category) => buildCategoryItem(
                  category['icon'],
                  category['label'],
                  category['color'],
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CategoriesCustomer(
                                onBackPress: widget.onBackPress,
                              ))),
                ))
            .toList(),
      ),
    );
  }

  Widget buildCategoryItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
                radius: 20,
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
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              // GestureDetector(
              //   onTap: () {
              //
              //   },
              //   child: Text(
              //     'View All',
              //     style: TextStyle(
              //       fontFamily: 'Poppins',
              //       fontWeight: FontWeight.bold,
              //       color: AppColors.customButton,
              //       fontSize: 16,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('service').snapshots(),
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
                      future: FirebaseFirestore.instance
                          .collection('provider')
                          .doc(serviceDoc['providerId'])
                          .get(),
                      builder: (context, providerSnapshot) {
                        if (!providerSnapshot.hasData) {
                          return Center(
                              child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ));
                        }
                        return buildServiceCard(
                            context, serviceDoc, providerSnapshot.data!);
                      });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildServiceCard(BuildContext context, DocumentSnapshot serviceDoc,
      DocumentSnapshot providerDoc) {
    // Assuming fields are correctly retrieved.
    String imageUrl =
        getDocumentField(serviceDoc, 'ImageUrl', 'default_image_url');
    String serviceName =
        getDocumentField(serviceDoc, 'ServiceName', 'No service name');
    String subcategory = getDocumentField(serviceDoc, 'Subcategory', 'General');
    String servicePrice =
        getDocumentField(serviceDoc, 'Price', 'Call for price');
    String providerPic =
        getDocumentField(providerDoc, 'ProfilePic', 'default_profile_pic_url');
    String providerName =
        getDocumentField(providerDoc, 'FirstName', 'No provider name');

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
                      SizedBox(width: 65,),
                      Text(
                        "\$" + servicePrice,
                        style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    subcategory,
                    style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold, color: Colors.blueGrey,),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(providerPic),
                    radius: 15,
                  ),
                  SizedBox(width: 20,),
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

  dynamic getDocumentField(DocumentSnapshot doc, String fieldName,
      [dynamic defaultValue = '']) {
    var data = doc.data() as Map<String, dynamic>?;
    return data != null && data.containsKey(fieldName)
        ? data[fieldName]
        : defaultValue;
  }
}
