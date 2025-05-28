// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:ecommerse_website/models/product.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartPage({
    super.key,
    required this.cartItems,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class CartItem {
  Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> items;
  final Set<int> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    items = List.from(widget.cartItems);
  }

  void _toggleSelection(int productId) {
    setState(() {
      if (_selectedItemIds.contains(productId)) {
        _selectedItemIds.remove(productId);
      } else {
        _selectedItemIds.add(productId);
      }
    });
  }

  void _selectAllItems() {
    setState(() {
      if (_selectedItemIds.length == items.length) {
        _selectedItemIds.clear();
      } else {
        for (var item in items) {
          _selectedItemIds.add(item.product.id);
        }
      }
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      items.removeWhere((item) => _selectedItemIds.contains(item.product.id));
      _selectedItemIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected items removed')),
    );
  }

  void increaseQuantity(int index) => setState(() => items[index].quantity++);
  void decreaseQuantity(int index) => setState(() { if (items[index].quantity > 1) items[index].quantity--; });

  double getSelectedItemsPrice() {
    double total = 0;
    for (var item in items) {
      if (_selectedItemIds.contains(item.product.id)) {
        total += item.product.price * item.quantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool hasSelection = _selectedItemIds.isNotEmpty;

    return Scaffold(
      /*appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),*/
      floatingActionButton: hasSelection ? _buildCheckoutFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          _buildSelectionHeader(),
          Expanded(child: _buildCartList()),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    bool hasSelection = _selectedItemIds.isNotEmpty;
    bool allSelected = hasSelection && _selectedItemIds.length == items.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: hasSelection ? 60 : 0,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: Icon(allSelected ? Icons.check_box : Icons.check_box_outline_blank),
              label: Text(allSelected ? 'Deselect All' : 'Select All (${_selectedItemIds.length})'),
              onPressed: _selectAllItems,
            ),
            TextButton.icon(
              icon: Icon(Icons.delete_outline, color: Colors.red[700]),
              label: Text('Delete', style: TextStyle(color: Colors.red[700])),
              onPressed: _deleteSelectedItems,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text('Your Cart is Empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add items from the store to see them here.', style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Add padding at the bottom to avoid FAB overlap
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = _selectedItemIds.contains(item.product.id);

        return InkWell(
          onTap: () => _toggleSelection(item.product.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleSelection(item.product.id),
                  activeColor: Colors.blueAccent,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.product.imageUrl, height: 80, width: 80, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text("\$${item.product.price.toStringAsFixed(2)}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildQuantityStepper(index),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityStepper(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () => decreaseQuantity(index), icon: const Icon(Icons.remove, size: 16)),
          Text(items[index].quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(onPressed: () => increaseQuantity(index), icon: const Icon(Icons.add, size: 16)),
        ],
      ),
    );
  }

  // --- FIX: Added GestureDetector to make the FAB tappable ---
  Widget _buildCheckoutFab() {
    return GestureDetector(
      onTap: () {
        // This is where the UI-only checkout action happens
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout for \$${getSelectedItemsPrice().toStringAsFixed(2)}! (UI Demo)'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${getSelectedItemsPrice().toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            const Text(
              'Checkout',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}