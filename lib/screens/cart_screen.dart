import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../models/product_model.dart';
import '../widget/custom_snackbar.dart';

class CartScreen extends StatefulWidget {
  final List<Product> cart;

  const CartScreen({required this.cart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _removeFromCart(Product product) {
    setState(() {
      widget.cart.remove(product);
    });

    void showCustomSnackBar(String message, bool isSuccess) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBarContent(
          success: isSuccess,
          message: message,
          onClose: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        displayDuration: const Duration(seconds: 1),
      );
    }

    showCustomSnackBar('${product.title}\nremoved from cart', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Your Cart'),
      ),
      body: widget.cart.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: widget.cart.length,
        itemBuilder: (context, index) {
          final product = widget.cart[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  product.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(product.title),
              subtitle: Text('\$${product.price}'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeFromCart(product),
              ),
            ),
          );
        },
      ),
    );
  }
}
