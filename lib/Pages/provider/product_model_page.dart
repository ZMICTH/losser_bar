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
        .where((product) => product.type == 'normal')
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
      int currentQuantity = _cart[productIndex]['quantity'] ?? 0;

      // Check if the current quantity is less than 10 before increasing
      if (currentQuantity < 10) {
        _cart[productIndex]['quantity'] = currentQuantity + 1;
      } else {
        // For example, using a snackbar or a dialog:
        print('Cannot increase quantity. Maximum of 10 items allowed.');
      }
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
    return _cart.fold(0.0,
        (total, current) => total + (current['price'] * current['quantity']));
  }

  double getTotalPricebyItem() {
    double totalItemPrice = 0.0;
    for (var item in _cart) {
      double itemPrice =
          item['price'] as double; // Make sure price is treated as double
      int itemQuantity =
          item['quantity'] as int; // Ensure quantity is treated as int
      totalItemPrice += itemPrice *
          itemQuantity; // Calculate total for each item and add to totalPrice
    }
    return totalItemPrice;
  }

  double getTotalQuantity() {
    return _cart.fold(0, (total, current) => total + current['quantity']);
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
