import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('https://api.escuelajs.co/api/v1/products');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
