// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:servtol/util/AppColors.dart';
// import 'package:servtol/util/uihelper.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// enum WageType { Free, Hourly, Fixed }
// enum ServiceType { Digital, Hybrid, Physical }
//
// // Enums for categories, subcategories, provinces, and cities are defined here...
//
// class ServicesAddition extends StatefulWidget {
//   const ServicesAddition({Key? key}) : super(key: key);
//
//   @override
//   _ServicesAdditionState createState() => _ServicesAdditionState();
// }
//
// class _ServicesAdditionState extends State<ServicesAddition> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   TextEditingController priceController = TextEditingController();
//   TextEditingController discountController = TextEditingController();
//   File? profilePic;
//   Category? selectedCategory;
//   Subcategory? selectedSubcategory;
//   Province? selectedProvince;
//   City? selectedCity;
//   WageType? selectedWageType;
//   ServiceType? selectedServiceType;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add New Service"),
//         backgroundColor: AppColors.background,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _selectImage,
//               child: CircleAvatar(
//                 radius: 64,
//                 backgroundColor: Colors.grey.shade300,
//                 backgroundImage: profilePic != null ? FileImage(profilePic!) : null,
//                 child: profilePic == null ? Icon(FontAwesomeIcons.camera, size: 50) : null,
//               ),
//             ),
//             SizedBox(height: 20),
//             buildTextField(nameController, "Service Name", FontAwesomeIcons.servicestack),
//             buildDropdown<Category>("Category", selectedCategory, Category.values, _onCategorySelected),
//             if (selectedCategory != null)
//               buildDropdown<Subcategory>("Subcategory", selectedSubcategory, subcategoryMap[selectedCategory]!, _onSubcategorySelected),
//             buildDropdown<Province>("Province", selectedProvince, Province.values, _onProvinceSelected),
//             if (selectedProvince != null)
//               buildDropdown<City>("City", selectedCity, provinceCitiesMap[selectedProvince]!, _onCitySelected),
//             buildTextField(priceController, "Price", FontAwesomeIcons.moneyBill, isNumber: true),
//             buildTextField(discountController, "Discount", FontAwesomeIcons.percent, isNumber: true),
//             buildTextField(descriptionController, "Description", FontAwesomeIcons.alignLeft),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _submitForm,
//               child: Text("Submit"),
//               style: ElevatedButton.styleFrom(primary: Colors.blue),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _selectImage() async {
//     final picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         profilePic = File(image.path);
//       });
//     }
//   }
//
//   void _onCategorySelected(Category? category) {
//     setState(() {
//       selectedCategory = category;
//       selectedSubcategory = null;  // Reset subcategory when category changes
//     });
//   }
//
//   void _onSubcategorySelected(Subcategory? subcategory) {
//     setState(() {
//       selectedSubcategory = subcategory;
//     });
//   }
//
//   void _onProvinceSelected(Province? province) {
//     setState(() {
//       selectedProvince = province;
//       selectedCity = null;  // Reset city when province changes
//     });
//   }
//
//   void _onCitySelected(City? city) {
//     setState(() {
//       selectedCity = city;
//     });
//   }
//
//   Widget buildDropdown<T>(String label, T? currentValue, List<T> values, void Function(T?) onChanged) {
//     return DropdownButtonFormField<T>(
//       value: currentValue,
//       onChanged: onChanged,
//       items: values.map<DropdownMenuItem<T>>((T value) {
//         return DropdownMenuItem<T>(
//           value: value,
//           child: Text(value.toString().split('.').last),
//         );
//       }).toList(),
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
//       ),
//     );
//   }
//
//   Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(),
//       ),
//       keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//     );
//   }
//
//   Future<void> _submitForm() async {
//     if (profilePic == null || selectedCategory == null || selectedSubcategory == null || selectedProvince == null || selectedCity == null || nameController.text.isEmpty || priceController.text.isEmpty || descriptionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please complete all fields")));
//       return;
//     }
//     try {
//       String imageUrl = await _uploadImageToFirebaseStorage();
//       await _saveDataToFirestore(imageUrl);
//       ScaffoldMessenger.of(context).showSnackBar





// class _servicesadditionState extends State<servicesaddition> {
//   List<Subcategory> availableSubcategories = [];
//   List<City> availableCities = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text("Your Services", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.heading)),
//         backgroundColor: AppColors.background,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Image picker and other inputs...
//             _buildCategoryDropdown(),
//             if (_selectedcategory != null)
//               _buildSubcategoryDropdown(),
//             _buildProvinceDropdown(),
//             if (_selectedprovince != null)
//               _buildCityDropdown(),
//             // Other input fields and buttons...
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCategoryDropdown() {
//     return DropdownButtonFormField<Category>(
//       value: _selectedcategory,
//       onChanged: (newValue) {
//         setState(() {
//           _selectedcategory = newValue;
//           availableSubcategories = newValue != null ? categorySubcategories[newValue] ?? [] : [];
//           _selectedsubcategory = null; // Reset subcategory when category changes
//         });
//       },
//       items: Category.values.map((category) {
//         return DropdownMenuItem(value: category, child: Text(category.toString().split('.').last));
//       }).toList(),
//       decoration: InputDecoration(labelText: "Category"),
//     );
//   }
//
//   Widget _buildSubcategoryDropdown() {
//     return DropdownButtonFormField<Subcategory>(
//       value: _selectedsubcategory,
//       onChanged: (newValue) {
//         setState(() {
//           _selectedsubcategory = newValue;
//         });
//       },
//       items: availableSubcategories.map((subcategory) {
//         return DropdownMenuItem(value: subcategory, child: Text(subcategory.toString().split('.').last));
//       }).toList(),
//       decoration: InputDecoration(labelText: "Sub-Category"),
//     );
//   }
//
//   Widget _buildProvinceDropdown() {
//     return DropdownButtonFormField<Province>(
//       value: _selectedprovince,
//       onChanged: (newValue) {
//         setState(() {
//           _selectedprovince = newValue;
//           availableCities = newValue != null ? provinceCities[newValue] ?? [] : [];
//           _selectedcity = null; // Reset city when province changes
//         });
//       },
//       items: Province.values.map((province) {
//         return DropdownMenuItem(value: province, child: Text(province.toString().split('.').last));
//       }).toList(),
//       decoration: InputDecoration(labelText: "Province"),
//     );
//   }
//
//   Widget _buildCityDropdown() {
//     return DropdownButtonFormField<City>(
//       value: _selectedcity,
//       onChanged: (newValue) {
//         setState(() {
//           _selectedcity = newValue;
//         });
//       },
//       items: availableCities.map((city) {
//         return DropdownMenuItem(value: city, child: Text(city.toString().split('.').last));
//       }).toList(),
//       decoration: InputDecoration(labelText: "City"),
//     );
//   }
// }




// Map<Category, List<Subcategory>> categorySubcategories = {
//   Category.DigitalMarketing: [
//     Subcategory.SEO,
//     Subcategory.SocialMediaMarketing,
//     Subcategory.EmailMarketing,
//     Subcategory.ContentMarketing,
//   ],
//   Category.OnlineConsultation: [
//     Subcategory.MedicalConsultation,
//     Subcategory.LegalConsultation,
//     Subcategory.FinancialConsultation,
//     Subcategory.PsychologicalCounseling,
//   ],
//   // Add more mappings...
// };
//
// Map<Province, List<City>> provinceCities = {
//   Province.Punjab: [
//     City.Lahore,
//     City.Faisalabad,
//     City.Multan,
//     // More cities...
//   ],
//   Province.Sindh: [
//     City.Karachi,
//     City.Hyderabad,
//     // More cities...
//   ],
//   // Add more mappings...
// };
