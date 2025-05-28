// lib/pages/home_page.dart

import 'dart:async';
import 'dart:convert';
import 'package:ecommerse_website/models/category.dart';
import 'package:ecommerse_website/models/product.dart';
import 'package:ecommerse_website/models/user.dart';
import 'package:ecommerse_website/pages/cart_page.dart';
import 'package:ecommerse_website/pages/categories_page.dart';
import 'package:ecommerse_website/pages/product_detail_page.dart';
import 'package:ecommerse_website/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final User loggedInUser;
  const HomePage({super.key, required this.loggedInUser});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  List<Product> allProducts = [];
  List<Category> categories = [];
  final Set<int> cart = {};
  final Set<int> favorites = {};
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Product> _filteredProducts = [];
  late final PageController _pageController;
  Timer? _bannerTimer;
  int _currentPage = 0;

  final List<String> _pageTitles = ['Discover', 'My Cart', 'Favorites', 'Messages', 'My Profile'];

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 700;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    fetchCategories();
    fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = query.isEmpty ? allProducts : allProducts.where((p) => p.title.toLowerCase().contains(query)).toList();
    });
  }

  void _startBannerTimer() {
    if (allProducts.isEmpty) return;
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % allProducts.take(5).length;
        _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bannerTimer?.cancel();
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('https://api.escuelajs.co/api/v1/categories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final filtered = data.map((item) => Category.fromJson(item)).where((cat) => cat.image.isNotEmpty && cat.image.startsWith('http')).toList();
        setState(() => categories = filtered.take(5).toList());
      }
    } catch (e) { print("Error fetching categories: $e"); }
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('https://api.escuelajs.co/api/v1/products');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final products = data.map((item) => Product.fromJson(item)).where((p) => p.imageUrl.isNotEmpty).toList()..shuffle();
        setState(() {
          allProducts = products;
          _filteredProducts = products;
        });
        _startBannerTimer();
      }
    } catch (e) { print("Error fetching products: $e"); }
  }

  void toggleCart(Product product) => setState(() => cart.contains(product.id) ? cart.remove(product.id) : cart.add(product.id));
  void toggleFavorite(Product product) => setState(() => favorites.contains(product.id) ? favorites.remove(product.id) : favorites.add(product.id));
  void _viewCart() => setState(() => currentIndex = 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: SafeArea(child: _buildPageContent()),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      ),
    );
  }

  AppBar _buildNormalAppBar() {
    return AppBar(
      key: const ValueKey('normal_app_bar'),
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(_pageTitles[currentIndex], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      actions: [
        if (currentIndex == 0)
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              setState(() => _isSearching = true);
              _searchFocusNode.requestFocus();
            },
            icon: Icon(Icons.search, color: Colors.black),
          ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () {},
          icon: Icon(Icons.notifications_none, color: Colors.black),
        ),
        PopupMenuButton<String>(
          onSelected: (value) { if (value == 'logout') Navigator.pushNamedAndRemoveUntil(context, '/user-selection', (route) => false); },
          itemBuilder: (context) => [ const PopupMenuItem<String>(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text("Logout")]))],
          padding: const EdgeInsets.only(right: 12.0, left: 4.0),
          child: CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.loggedInUser.avatar)),
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      key: const ValueKey('search_app_bar'),
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => setState(() { _isSearching = false; _searchController.clear(); })),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search for products...',
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => _searchController.clear()) : null,
        ),
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (currentIndex) {
      case 0: return _buildHomeTab();
      case 1: return _buildCartTab();
      case 2: return _buildFavoritesTab();
      case 3: return _buildMessagesTab();
      case 4: return _buildProfileTab();
      default: return const Center(child: Text("Page not found"));
    }
  }

  Widget _buildHomeTab() {
    int gridCrossAxisCount = isMobile(context) ? 2 : (MediaQuery.of(context).size.width > 1200 ? 5 : 4);
    double gridChildAspectRatio = isMobile(context) ? 0.75 : 0.85;
    final showBannerAndCategories = !_isSearching && _searchController.text.isEmpty;

    return allProducts.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBannerAndCategories) ...[
            _buildBanner(),
            _buildSectionHeader("Categories", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesPage()));
            }),
            isMobile(context) ? _horizontalCategoryList() : _expandedCategoryRow(),
          ],
          _buildSectionHeader(_searchController.text.isNotEmpty ? 'Search Results' : 'For You', () {}),
          _gridProductList(gridCrossAxisCount, gridChildAspectRatio),
        ],
      ),
    );
  }

  Widget _horizontalCategoryList() {
    final colors = [Colors.blue.shade50, Colors.red.shade50, Colors.green.shade50, Colors.orange.shade50, Colors.purple.shade50];
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryTile(category, colors[index % colors.length]);
        },
      ),
    );
  }

  Widget _expandedCategoryRow() {
    final colors = [Colors.blue.shade50, Colors.red.shade50, Colors.green.shade50, Colors.orange.shade50, Colors.purple.shade50];
    if (categories.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: Text("Loading categories...")));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildCategoryTile(categories[i], colors[i % colors.length]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(Category category, Color color) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 25, backgroundColor: Colors.white, backgroundImage: NetworkImage(category.image)),
          const SizedBox(height: 8),
          Text(category.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: allProducts.take(5).length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final product = allProducts[index];
              // --- BANNER CLICK FIX: Wrap the banner item with GestureDetector and Hero ---
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                child: Hero(
                  // Use a unique tag that matches the one in ProductDetailPage
                  tag: 'product_image_${product.id}',
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(product.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(allProducts.take(5).length, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 8,
            width: _currentPage == index ? 24 : 8,
            decoration: BoxDecoration(color: _currentPage == index ? Colors.blueAccent : Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
          ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          TextButton(onPressed: onViewAll, child: const Text("See All")),
        ],
      ),
    );
  }
  Widget _gridProductList(int crossAxisCount, double childAspectRatio) {
    if (_filteredProducts.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("No products found for your search.", textAlign: TextAlign.center)));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductTileWithButtons(
          product: product,
          isFavorite: favorites.contains(product.id),
          isInCart: cart.contains(product.id),
          onToggleCart: () => toggleCart(product),
          onToggleFavorite: () => toggleFavorite(product),
          onViewCart: _viewCart,
        );
      },
    );
  }
  Widget _buildCartTab() {
    final cartProductObjects = allProducts.where((p) => cart.contains(p.id)).toList();
    final cartItems = cartProductObjects.map((product) => CartItem(product: product)).toList();
    return CartPage(cartItems: cartItems);
  }
  Widget _buildFavoritesTab() {
    final favoriteProducts = allProducts.where((p) => favorites.contains(p.id)).toList();
    return favoriteProducts.isEmpty ? const Center(child: Text('No favorites added.')) : GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile(context) ? 2 : 4,
        childAspectRatio: 0.75,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        return ProductTileWithButtons(
          product: product,
          isFavorite: favorites.contains(product.id),
          isInCart: cart.contains(product.id),
          onToggleCart: () => toggleCart(product),
          onToggleFavorite: () => toggleFavorite(product),
          onViewCart: _viewCart,
        );
      },
    );
  }
  Widget _buildMessagesTab() => const Center(child: Text("Messages tab"));
  Widget _buildProfileTab() => ProfilePage(user: widget.loggedInUser);
  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey[600],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

class ProductTileWithButtons extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final bool isInCart;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleCart;
  final VoidCallback onViewCart;

  const ProductTileWithButtons({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.isInCart,
    required this.onToggleFavorite,
    required this.onToggleCart,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
      },
      child: Hero(
        tag: 'product_image_${product.id}',
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const Spacer(),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 22),
                          onPressed: onToggleFavorite,
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: Icon(isInCart ? Icons.check_circle : Icons.add_shopping_cart, color: isInCart ? Colors.green : Colors.blue, size: 22),
                          onPressed: isInCart ? onViewCart : onToggleCart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}