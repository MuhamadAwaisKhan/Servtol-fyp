import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';

class CategoriesCustomer extends StatefulWidget {
  Function onBackPress; // Making this final and required


   CategoriesCustomer({Key? key,required this.onBackPress}) : super(key: key);

  @override
  State<CategoriesCustomer> createState() => _CategoriesCustomerState();
}

class _CategoriesCustomerState extends State<CategoriesCustomer> {
  final List<Category> categories = [
    Category(name: 'Marketing', icon: Icons.shopping_basket),
    Category(name: 'Consultation', icon: Icons.chat),
    Category(name: 'Events', icon: Icons.event),
    Category(name: 'Cloud Storage', icon: Icons.cloud),
    Category(name: 'Web Dev', icon: Icons.language),
    Category(name: 'App Dev', icon: Icons.phone_android),
    Category(name: 'Social Media', icon: Icons.group),
    Category(name: 'SEO', icon: Icons.search),
    Category(name: 'Design', icon: Icons.brush),
    Category(name: 'Video Edit', icon: Icons.videocam),
    Category(name: 'Support', icon: Icons.desktop_windows),
    Category(name: 'E-Commerce', icon: Icons.shopping_cart),
    Category(name: 'Training', icon: Icons.school),
    Category(name: 'Telemedicine', icon: Icons.local_hospital),
    Category(name: 'Remote Work', icon: Icons.work),
    Category(name: 'Mixed Reality', icon: Icons.videogame_asset),
    Category(name: 'Virtual Tour', icon: Icons.explore),
    Category(name: 'Cleaning', icon: Icons.cleaning_services),
    Category(name: 'Plumbing', icon: Icons.plumbing),
    Category(name: 'Electrician', icon: Icons.electrical_services),
    Category(name: 'Car Repair', icon: Icons.car_repair),
    Category(name: 'Catering', icon: Icons.restaurant),
    Category(name: 'Fitness', icon: Icons.fitness_center),
    Category(name: 'Event Plan', icon: Icons.event),
    // Add your category details here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Categories', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.heading)),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: GridView.builder(
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
        print('Clicked on ${category.name}');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            category.icon!,
            size: 50,
            color: Colors.indigo,
          ),
          SizedBox(height: 4),
          Text(
            category.name,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class Category {
  final String name;
  final IconData? icon;

  Category({required this.name, required this.icon});
}
