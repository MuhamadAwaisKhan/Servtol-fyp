// product.dart

class Product {
  final String name;
  final String description;
  final String createdDate;
  final String updatedDate;
  final double price;
  final String type;

  Product({
    required this.name,
    required this.description,
    required this.createdDate,
    required this.updatedDate,
    required this.price,
    required this.type,
  });
}