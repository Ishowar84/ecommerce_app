// lib/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailPage extends StatelessWidget { // --- MODIFIED: Changed to StatelessWidget ---
  final Product product;
  // --- NEW: Accepting state and callbacks from the parent ---
  final bool isFavorite;
  final bool isInCart;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onViewCart;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.isInCart,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onViewCart,
  });

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            // --- MODIFIED: Use the passed-in callback ---
            onPressed: () {
              onToggleFavorite();
              _showSnackBar(context, !isFavorite ? 'Added to favorites' : 'Removed from favorites');
            },
            icon: Icon(
              // --- MODIFIED: Use the passed-in state ---
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CRITICAL FIX: Added Hero widget to enable animation ---
            Hero(
              tag: 'product_image_${product.id}',
              child: _ImageGallery(product: product),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // A persistent bottom bar for the "Add to Cart" button
  Widget _buildBottomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        // --- MODIFIED: Button changes based on whether the item is in the cart ---
        child: isInCart
            ? ElevatedButton.icon(
          onPressed: onViewCart, // Go to cart if already added
          icon: const Icon(Icons.shopping_cart_checkout),
          label: const Text("Go to Cart"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Different color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )
            : ElevatedButton.icon(
          onPressed: () {
            onAddToCart(); // Use the callback
            _showSnackBar(context, 'Added to cart');
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text("Add to Cart"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

// --- NEW: Extracted Image Gallery to its own StatefulWidget to manage its internal state ---
class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.product});

  final Product product;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // Check for empty images list to prevent crash
    final bool hasImages = widget.product.images.isNotEmpty;

    return Column(
      children: [
        Container(
          height: 300,
          color: Colors.grey[200],
          child: hasImages
              ? PageView.builder(
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.product.images.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.product.images[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 100,
                  color: Colors.grey,
                ),
              );
            },
          )
              : Center(
            child: Image.network(
              widget.product.imageUrl, // Fallback to main image
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                size: 100,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        if (hasImages && widget.product.images.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.product.images.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.blueAccent : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
        ]
      ],
    );
  }
}