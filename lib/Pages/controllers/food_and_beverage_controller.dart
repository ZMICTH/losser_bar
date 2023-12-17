import 'dart:async';

import 'package:losser_bar/Pages/Model/food_and_beverage_model.dart';
import 'package:losser_bar/Pages/services/food_and_beverage_service.dart';

class FoodAndBeverageController {
  List<FoodAndBeverageProduct> FoodAndBeverageProducts = List.empty();
  final FoodAndBeverageService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  FoodAndBeverageController(this.service);

  Future<List<FoodAndBeverageProduct>> fetchFoodAndBeverageProduct() async {
    print("fetchFoodAndBeverageProduct was: ${FoodAndBeverageProducts}");
    onSyncController.add(true);
    FoodAndBeverageProducts = await service.getAllFoodAndBeverageProduct();
    onSyncController.add(false);
    return FoodAndBeverageProducts;
  }

  void updateFoodAndBeverageProduct(
      FoodAndBeverageProduct foodandbeverageproduct) async {
    service.updateFoodAndBeverageProduct(foodandbeverageproduct);
  }
}
