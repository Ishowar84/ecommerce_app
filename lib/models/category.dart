// lib/models/category.dart

class Category {
  final int id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? 'No Name', // Handle potential null names
      image: json['image'] ?? '', // Handle potential null images
    );
  }
}