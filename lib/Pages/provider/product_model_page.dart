import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:losser_bar/Pages/Model/food_and_beverage_model.dart';
import 'package:losser_bar/Pages/services/food_and_beverage_service.dart';

//get product by type
class ProductModel extends ChangeNotifier {
  List<FoodAndBeverageProduct> _foodAndBeverageProducts = [];
  List<FoodAndBeverageProduct> _products = [];
  List<FoodAndBeverageProduct> _promotions = [];

  final List _cart = [];

  List<FoodAndBeverageProduct> get products => _products;
  List<FoodAndBeverageProduct> get promotions => _promotions;
  get cart => _cart;

  void setFoodAndBeverageProducts(
      List<FoodAndBeverageProduct> foodAndBeverageProducts) {
    _foodAndBeverageProducts = foodAndBeverageProducts;
    _filterProductsAndPromotions();
    notifyListeners();
  }

  void _filterProductsAndPromotions() {
    _products = _foodAndBeverageProducts
        .where((product) => product.type == 'product')
        .toList();
    _promotions = _foodAndBeverageProducts
        .where((product) => product.type == 'promotion')
        .toList();
  }

// This method finds a product in the cart based on its ID.
  int _findProductIndex(Map<String, dynamic> product) {
    return _cart.indexWhere((item) => item['id'] == product['id']);
  }

  void addToCart(Map<String, dynamic> product) {
    // Find the product in the cart, regardless of its type.
    int productIndex = _findProductIndex(product);

    if (productIndex != -1) {
      _cart[productIndex]['quantity'] =
          (_cart[productIndex]['quantity'] ?? 0) + 1;
    } else {
      product['quantity'] = 1;
      _cart.add(product);
    }

    print(product);
    notifyListeners();
  }

  void increaseQuantity(Map<String, dynamic> product) {
    // Find the product in the cart based on its ID
    int productIndex = _findProductIndex(product);

    // If the product is found in the cart, increase its quantity
    if (productIndex != -1) {
      _cart[productIndex]['quantity'] =
          (_cart[productIndex]['quantity'] ?? 0) + 1;
    }

    notifyListeners();
  }

  void decreaseQuantity(Map<String, dynamic> product) {
    int productIndex = _findProductIndex(product);

    if (productIndex != -1) {
      int currentQuantity = _cart[productIndex]['quantity'] ?? 1;
      if (currentQuantity > 1) {
        _cart[productIndex]['quantity'] = currentQuantity - 1;
      } else {
        _cart.removeAt(productIndex);
      }
    }
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> product) {
    _cart.removeWhere((item) => item['id'] == product['id']);
    notifyListeners();
  }

  double getTotalPrice() {
    double totalPrice = 0;

    for (var item in _cart) {
      // Assuming both product types use 'price' as their key for price
      double itemPrice = (item['price'] ?? 0).toDouble();
      int itemQuantity = item['quantity'] ?? 1;
      totalPrice += itemPrice * itemQuantity;
    }

    return totalPrice;
  }

  int _getTotalQuantity(List<Map<String, dynamic>> cart) {
    int totalQuantity = 0;
    for (var product in cart) {
      totalQuantity += (product['quantity'] as num ?? 0).toInt();
    }
    return totalQuantity;
  }

  void clearproduct() {
    cart.clear();
    notifyListeners();
  }

  Future<void> fetchFoodAndBeverageProducts() async {
    // Fetch products from Firebase or other source
    // Example:
    var foodandbeverageProducts =
        await FoodAndBeverageFirebaseService().getAllFoodAndBeverageProduct();
    setFoodAndBeverageProducts(foodandbeverageProducts);
  }
}
