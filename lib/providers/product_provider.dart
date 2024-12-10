import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final String baseUrl = "http://192.168.167.19:3000/product"; // Update with your backend URL

  List<Product> _products = []; // List to store products locally

  // Getter for the products list
  List<Product> get products => _products;

  


  // Add a new product
  Future<void> addProduct(Product product) async {
    try {
      // You should add the product to your data source here (e.g., API, local database)
      // Simulating a network/database delay for now
      await Future.delayed(Duration(seconds: 2));
      _products.add(product);
      notifyListeners();  // Notify listeners of changes
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }


  // Update an existing product
  Future<void> updateProduct(Product updatedProduct) async {
    try {
      // Update the product in the data source (e.g., API, local database)
      await Future.delayed(Duration(seconds: 2));
      int index = _products.indexWhere((product) => product.id == updatedProduct.id);
      if (index >= 0) {
        _products[index] = updatedProduct;
        notifyListeners();  // Notify listeners of changes
      } else {
        throw 'Product not found';
      }
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }


  // Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        // Remove the deleted product from the local list
        _products.removeWhere((product) => product.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

// Fetch products by category
  Future<void> fetchProductsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/category/$category'));
      if (response.statusCode == 200) {
        _products = (json.decode(response.body) as List)
            .map((item) => Product.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load products by category');
      }
    } catch (e) {
      throw Exception('Failed to load products by category: $e');
    }
  }

  // Fetch products by name
  Future<void> fetchProductsByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/name/$name'));
      if (response.statusCode == 200) {
        _products = (json.decode(response.body) as List)
            .map((item) => Product.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load products by name');
      }
    } catch (e) {
      throw Exception('Failed to load products by name: $e');
    }
  }


  Future<void> fetchProducts() async {
  try {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      _products = (json.decode(response.body) as List)
          .map((item) => Product.fromJson(item))
          .toList();
      notifyListeners(); // Notify listeners to update the UI
    } else {
      throw Exception('Failed to load products: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to load products: $e');
  }
}

}
