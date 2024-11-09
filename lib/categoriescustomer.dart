import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:servtol/Categorybyservices.dart';
import 'package:servtol/util/AppColors.dart';

class CategoriesCustomer extends StatefulWidget {
  final Function onBackPress; // Making this final and required

  CategoriesCustomer({Key? key, required this.onBackPress}) : super(key: key);

  @override
  State<CategoriesCustomer> createState() => _CategoriesCustomerState();
}

class _CategoriesCustomerState extends State<CategoriesCustomer> {
  // This list will store the fetched categories
  List<Category> categories = [];

  // Predefined map for category names to icons
  Map<String, IconData> categoryIconMap = {
    'Healthcare': FontAwesomeIcons.hospital,
    'Design & Multimedia': FontAwesomeIcons.paintBrush,
    'Telemedicine': FontAwesomeIcons.hospital,
    'Education': FontAwesomeIcons.school,
    'Retail': FontAwesomeIcons.store,
    'Online Services': FontAwesomeIcons.globe,
    'Development': FontAwesomeIcons.cogs,
    'Online Consultation': FontAwesomeIcons.comments,
    'Digital Marketing': FontAwesomeIcons.chartLine,
    'Online Training': FontAwesomeIcons.chalkboardTeacher,
    'Event Management': FontAwesomeIcons.calendarAlt,
    'Video Editing': FontAwesomeIcons.video,
    'Home & Maintenance ': FontAwesomeIcons.home,
    'Hospitality': FontAwesomeIcons.utensils,
    'Social Media Management': FontAwesomeIcons.users,
    'IT Support': FontAwesomeIcons.laptop,
    'Personal & Lifestyle ': FontAwesomeIcons.user,
    'Graphic Design': FontAwesomeIcons.paintBrush,
    'Finance': FontAwesomeIcons.coins,
  };

  // Predefined map for category names to colors
  // Map<String, Color> categoryColorMap = {
  //   'Healthcare': Colors.green,
  //   'Design & Multimedia': Colors.purple,
  //   'Telemedicine': Colors.blue,
  //   'Education': Colors.orange,
  //   'Retail': Colors.yellow,
  //   'Online Services': Colors.teal,
  //   'Development': Colors.blueAccent,
  //   'Online Consultation': Colors.cyan,
  //   'Digital Marketing': Colors.indigo,
  //   'Online Training': Colors.deepOrange,
  //   'Event Management': Colors.red,
  //   'Video Editing': Colors.pink,
  //   'Home & Maintenance ': Colors.brown,
  //   'Hospitality': Colors.greenAccent,
  //   'Social Media Management': Colors.deepPurple,
  //   'IT Support': Colors.grey,
  //   'Personal & Lifestyle ': Colors.lime,
  //   'Graphic Design': Colors.amber,
  //   'Finance': Colors.green[700]!,
  // };

  // Fetch categories from Firebase
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Assuming your categories are stored in the "categories" collection
    CollectionReference categoriesRef = firestore.collection('Category');

    try {
      // Fetch category data from Firebase
      QuerySnapshot snapshot = await categoriesRef.get();
      List<Category> fetchedCategories = snapshot.docs.map((doc) {
        String categoryName = doc['Name'];
        IconData? categoryIcon = categoryIconMap[categoryName] ??
            FontAwesomeIcons.questionCircle; // Default icon if no match
        // Color categoryColor = categoryColorMap[categoryName] ?? Colors.black; // Default color if no match
        return Category(
          name: categoryName, icon: categoryIcon,
          // color: categoryColor
        );
      }).toList();

      setState(() {
        categories = fetchedCategories; // Update the categories list
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Categories',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.heading)),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: categories.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while fetching data
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryWidget(category: categories[index]);
              },
            ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final Category category;

  CategoryWidget({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryServicesScreen(categoryName: category.name),
          ),
        );
        // print('Clicked on ${category.name}');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            category.icon,
            size: 50,
            color:Colors.blueAccent
            // category.color, // Use the color associated with the category
          ),
          SizedBox(height: 4),
          Text(
            category.name,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                // color: category.color,
                color:AppColors.heading,

            ), // Use the same color for text
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class Category {
  final String name;
  final IconData icon;
  // final Color color;

  Category({required this.name, required this.icon,
    // required this.color
  });
}

