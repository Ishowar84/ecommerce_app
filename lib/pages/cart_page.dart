// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:ecommerse_website/models/product.dart'; // Assuming this path is correct

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  // --- CHANGE 1: Add a callback for when items should be removed ---
  final Function(Set<int> productIds) onItemsRemoved;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onItemsRemoved, // Make it required
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
  // We can now directly use widget.cartItems, but keeping a local copy
  // is still fine for managing quantity changes that might not be persisted immediately.
  // For simplicity and correctness with deletion, we'll directly reference the widget's list.
  final Set<int> _selectedItemIds = {};

  // initState is no longer needed to copy the list.

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
      if (_selectedItemIds.length == widget.cartItems.length) {
        _selectedItemIds.clear();
      } else {
        for (var item in widget.cartItems) {
          _selectedItemIds.add(item.product.id);
        }
      }
    });
  }

  // --- CHANGE 2: Call the callback instead of modifying local state ---
  void _deleteSelectedItems() {
    // Call the function passed from the parent widget
    widget.onItemsRemoved(_selectedItemIds);

    // Clear the local selection state
    setState(() {
      _selectedItemIds.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected items removed')),
    );
  }

  // Note: These quantity functions still only modify the local state.
  // If you want quantity changes to persist, you'll need to apply the same
  // callback pattern for them. For now, we'll leave them as-is.
  void increaseQuantity(int index) => setState(() => widget.cartItems[index].quantity++);
  void decreaseQuantity(int index) => setState(() { if (widget.cartItems[index].quantity > 1) widget.cartItems[index].quantity--; });


  double getSelectedItemsPrice() {
    double total = 0;
    for (var item in widget.cartItems) {
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
      /* ... AppBar ... */
      floatingActionButton: hasSelection ? _buildCheckoutFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: widget.cartItems.isEmpty
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
    bool allSelected = hasSelection && _selectedItemIds.length == widget.cartItems.length;

    return AnimatedContainer(
      // ... same as before
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
    // ... same as before
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      // --- CHANGE 3: Use widget.cartItems instead of the local 'items' list ---
      itemCount: widget.cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = widget.cartItems[index];
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
          Text(widget.cartItems[index].quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(onPressed: () => increaseQuantity(index), icon: const Icon(Icons.add, size: 16)),
        ],
      ),
    );
  }

  Widget _buildCheckoutFab() {
    // ... same as before
    return GestureDetector(
      onTap: () {
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