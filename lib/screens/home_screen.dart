import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../api_service/all_product.dart';
import '../models/product_model.dart';
import '../colors.dart'; // Assuming this contains your color constants
import '../widget/custom_snackbar.dart'; // Assuming this is for your custom snackbar
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Product>> futureProducts;
  final List<Product> _cart = [];
  final TextEditingController _searchController = TextEditingController();

  // Filters
  bool _isLowPriceSelected = false;
  bool _isHighPriceSelected = false;
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    futureProducts = ApiService.fetchProducts();
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });

    // Show custom snackbar
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBarContent(
        success: true,
        message: '${product.title} added to cart',
        onClose: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      displayDuration: const Duration(seconds: 1),
    );
  }

  List<Product> _applyFilters(List<Product> products) {
    return products.where((product) {
      final name = product.title.toLowerCase();
      final query = _searchController.text.toLowerCase();

      bool matchesSearch = query.isEmpty || name.contains(query);
      bool matchesPriceRange = true;
      bool matchesCategory = true;

      if (_isLowPriceSelected && product.price > 50) {
        matchesPriceRange = false;
      }

      if (_isHighPriceSelected && product.price <= 50) {
        matchesPriceRange = false;
      }

      if (_selectedCategories.isNotEmpty && !_selectedCategories.contains(product.category)) {
        matchesCategory = false;
      }

      return matchesSearch && matchesPriceRange && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Filter Options',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            CheckboxListTile(
              title: const Text('Low Price (< \$50)'),
              value: _isLowPriceSelected,
              onChanged: (bool? value) {
                setState(() {
                  _isLowPriceSelected = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('High Price (>= \$50)'),
              value: _isHighPriceSelected,
              onChanged: (bool? value) {
                setState(() {
                  _isHighPriceSelected = value ?? false;
                });
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            CheckboxListTile(
              title: const Text("Men's Clothing"),
              value: _selectedCategories.contains("men's clothing"),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedCategories.add("men's clothing");
                  } else {
                    _selectedCategories.remove("men's clothing");
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Jewelery'),
              value: _selectedCategories.contains('jewelery'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedCategories.add('jewelery');
                  } else {
                    _selectedCategories.remove('jewelery');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Electronics'),
              value: _selectedCategories.contains('electronics'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedCategories.add('electronics');
                  } else {
                    _selectedCategories.remove('electronics');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text("Women's Clothing"),
              value: _selectedCategories.contains("women's clothing"),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedCategories.add("women's clothing");
                  } else {
                    _selectedCategories.remove("women's clothing");
                  }
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartScreen(cart: _cart),
            ),
          );
        },
        backgroundColor: calendar5,
        child: const Icon(Icons.shopping_cart),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {}); // Rebuild the widget to update the product list
              },
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final products = snapshot.data ?? [];
                  final filteredProducts = _applyFilters(products);

                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '\$${product.price}',
                                  style: const TextStyle(color: cartcolor, fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: lightblue,
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                  onPressed: () => _addToCart(product),
                                  child: const Text('Add to Cart'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
