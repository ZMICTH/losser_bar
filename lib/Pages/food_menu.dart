import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailproductModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _promotion = [
    {
      'name': 'Singcha Beer 3 Bottles',
      'price': '260',
      'imagePath': "images/bottle_brown.jpg",
    },
    {
      'name': 'Chang Beer 3 Bottles',
      'price': '215',
      'imagePath': "images/bottle_green.jpg",
    },
    {
      'name': 'Leo Beer 3 Bottles',
      'price': '240',
      'imagePath': "images/bottle_brown.jpg",
    },
  ];
  final List<Map<String, dynamic>> _product = [
    {
      'name': 'Singcha Beer 1 Bottles',
      'price': '100',
      'imagePath': "images/bottle_brown.jpg",
    },
    {
      'name': 'Chang Beer 1 Bottles',
      'price': '85',
      'imagePath': "images/bottle_green.jpg",
    },
    {
      'name': 'Leo Beer 1 Bottles',
      'price': '95',
      'imagePath': "images/bottle_brown.jpg",
    },
    {
      'name': 'มันฝรั่งทอด',
      'price': '95',
      'imagePath': "images/fries.jpg",
    },
    {
      'name': 'เอ็นไก่ทอด',
      'price': '60',
      'imagePath': "images/enkai.jpg",
    },
  ];
  final List _cart = [];

  get promotions => this._promotion;
  get products => this._product;

  get Cart => this._cart;

  void addToBag(Map<String, dynamic> product) {
    _cart.add(product);
    notifyListeners(); // Notify listeners to rebuild relevant widgets
  }
}
