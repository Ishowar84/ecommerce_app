// lib/models/product.dart

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
  });

  // This getter provides a single image URL for the UI,
  // preventing errors if the images list is empty.
  String get imageUrl {
    if (images.isNotEmpty && images.first.isNotEmpty) {
      // Basic check to ensure the URL is valid
      if (images.first.startsWith('["') && images.first.endsWith('"]')) {
        return images.first.substring(2, images.first.length - 2);
      }
      return images.first;
    }
    // Return a placeholder image if no images are available
    return 'https://via.placeholder.com/150';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // The price can sometimes be an integer, so we parse it safely.
    final priceValue = json['price'];
    final double price = priceValue is int ? priceValue.toDouble() : (priceValue ?? 0.0);

    return Product(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      price: price,
      description: json['description'] ?? 'No Description',
      // The API gives a list of images, so we parse it as such.
      images: List<String>.from(json['images'] ?? []),
    );
  }
}