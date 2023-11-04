import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProductModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _promotion = [
    {
      "id": "PM-1001",
      "brand": "Singcha",
      "description": "",
      'name': 'Singcha Beer',
      'item': '3',
      'unit': 'Bottle',
      'price': 260,
      'imagePath': "images/bottle_brown.jpg",
    },
    {
      "id": "PM-1002",
      "brand": "Chang",
      "description": "",
      'name': 'Chang Beer',
      'item': '3',
      'unit': 'Bottle',
      'price': 215,
      'imagePath': "images/bottle_green.jpg",
    },
    {
      "id": "PM-1003",
      "brand": "Leo",
      "description": "",
      'name': 'Leo Beer',
      'item': '3',
      'unit': 'Bottle',
      'price': 240,
      'imagePath': "images/bottle_brown.jpg",
    },
    {
      "id": "PM-1004",
      "brand": "Hennessy",
      "description": "",
      'name': 'Hennessy VS',
      'item': '2',
      'unit': 'Bottle',
      'price': 3790,
      'imagePath': "images/hennessy_vs.jpg",
    },
    {
      "id": "PM-1005",
      "brand": "Jameson",
      "description": "",
      'name': 'Jameson',
      'item': '2',
      'unit': 'Bottle',
      'price': 1890,
      'imagePath': "images/jameson.jpg",
    },
  ];
  final List<Map<String, dynamic>> _product = [
    {
      "id": "RM-1001",
      "brand": "Singcha",
      "description": "",
      'name': 'Singcha Beer',
      'item': '1',
      'unit': 'Bottle',
      'price': 100,
      'imagePath': "images/bottle_brown.jpg",
    },
    {
      "id": "RM-1002",
      "brand": "Chang",
      "description": "",
      'name': 'Chang Beer',
      'item': '1',
      'unit': 'Bottle',
      'price': 85,
      'imagePath': "images/bottle_green.jpg",
    },
    {
      "id": "RM-1003",
      "brand": "Leo",
      "description": "",
      'name': 'Leo Beer',
      'item': '1',
      'unit': 'Bottle',
      'price': 95,
      'imagePath': "images/bottle_brown.jpg",
    },
    {
      "id": "RM-1004",
      "brand": "Hennessy",
      "description": "",
      'name': 'Hennessy VS',
      'item': '1',
      'unit': 'Bottle',
      'price': 1990,
      'imagePath': "images/hennessy_vs.jpg",
    },
    {
      "id": "RM-1005",
      "brand": "Jameson",
      "description": "",
      'name': 'Jameson',
      'item': '1',
      'unit': 'Bottle',
      'price': 1100,
      'imagePath': "images/jameson.jpg",
    },
    {
      "id": "RM-1006",
      "brand": "Absolut",
      "description": "",
      'name': 'Absolut Vodka',
      'item': '1',
      'unit': 'Bottle',
      'price': 790,
      'imagePath': "images/absolut_vodka.jpg",
    },
    {
      "id": "RM-1007",
      "brand": "Snacks",
      "description": "",
      'name': 'มันฝรั่งทอด',
      'item': '1',
      'unit': 'Dish',
      'price': 95,
      'imagePath': "images/fries.jpg",
    },
    {
      "id": "RM-1008",
      "brand": "Snacks",
      "description": "",
      'name': 'เอ็นไก่ทอด',
      'item': '1',
      'unit': 'Dish',
      'price': 60,
      'imagePath': "images/enkai.jpg",
    },
  ];

  final List _cart = [];

  get promotions => this._promotion;
  get products => this._product;

  get cart => this._cart;

  int _findProductIndex(Map<String, dynamic> product) {
    return _cart.indexWhere((item) => item['id'] == product['id']);
  }

  void _updateCart() {
    print(_cart);
    notifyListeners();
  }

  void addToCart(Map<String, dynamic> product) {
    int productIndex = _findProductIndex(product);

    if (productIndex != -1) {
      _cart[productIndex]['quantity'] =
          (_cart[productIndex]['quantity'] ?? 0) + 1;
    } else {
      product['quantity'] = (product['quantity'] ?? 0) + 1;
      _cart.add(product);
    }

    _updateCart();
  }

  void increaseQuantity(Map<String, dynamic> product) {
    int productIndex = _findProductIndex(product);

    if (productIndex != -1) {
      _cart[productIndex]['quantity'] =
          (_cart[productIndex]['quantity'] ?? 0) + 1;
    }

    _updateCart();
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

    _updateCart();
  }

  void removeFromCart(Map<String, dynamic> product) {
    _cart.removeWhere((item) => item['id'] == product['id']);
    _updateCart();
  }

  double getTotalPrice() {
    double totalPrice = 0;

    for (var item in _cart) {
      int itemPrice = item['price'] ?? 0;
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
}
