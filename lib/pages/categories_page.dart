
// lib/pages/categories_page.dart

import 'dart:convert';
import 'package:ecommerse_website/models/category.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> _allCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllCategories();
  }

  Future<void> _fetchAllCategories() async {
    try {
      final url = Uri.parse('https://api.escuelajs.co/api/v1/categories');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final filtered = data
            .map((item) => Category.fromJson(item))
            .where((cat) => cat.image.isNotEmpty && cat.image.startsWith('http'))
            .toList();

        if (mounted) {
          setState(() {
            _allCategories = filtered;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine grid columns based on screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200 ? 5 : (screenWidth > 800 ? 4 : 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allCategories.isEmpty
          ? const Center(child: Text('No categories found.'))
          : GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0, // Makes the tiles square
        ),
        itemCount: _allCategories.length,
        itemBuilder: (context, index) {
          return _CategoryGridTile(category: _allCategories[index]);
        },
      ),
    );
  }
}

// A dedicated widget for the category tile for cleaner code
class _CategoryGridTile extends StatelessWidget {
  final Category category;

  const _CategoryGridTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to a page showing products of this category
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped on ${category.name}')),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          child: Image.network(
            category.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }
}