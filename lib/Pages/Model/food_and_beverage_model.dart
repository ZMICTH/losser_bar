import 'package:cloud_firestore/cloud_firestore.dart';

class FoodAndBeverageProduct {
  String id = "";
  late String nameFoodBeverage;
  late int priceFoodBeverage;
  String foodbeverageimagePath;
  late String item;
  late String unit;
  String type;

  FoodAndBeverageProduct(
    this.nameFoodBeverage,
    this.priceFoodBeverage,
    this.foodbeverageimagePath,
    this.item,
    this.unit,
    this.type,
  );
  factory FoodAndBeverageProduct.fromJson(Map<String, dynamic> json) {
    print("FoodAndBeverageProduct.fromJson");
    print(json);
    return FoodAndBeverageProduct(
      json['nameFoodBeverage'] as String,
      json['priceFoodBeverage'] as int,
      json['foodbeverageimagePath'] as String,
      json['item'] as String,
      json['unit'] as String,
      json['type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': nameFoodBeverage,
      'price': priceFoodBeverage,
      'imagePath': foodbeverageimagePath,
      'item': item,
      'unit': unit,
      'type': type,
    };
  }
}

class AllFoodAndBeverageProduct {
  final List<FoodAndBeverageProduct> FoodAndBeverageProducts;

  AllFoodAndBeverageProduct(
      this.FoodAndBeverageProducts); // for Todo read each list from json

  factory AllFoodAndBeverageProduct.fromJson(List<dynamic> json) {
    List<FoodAndBeverageProduct> FoodAndBeverageProducts;

    FoodAndBeverageProducts =
        json.map((item) => FoodAndBeverageProduct.fromJson(item)).toList();

    return AllFoodAndBeverageProduct(FoodAndBeverageProducts);
  }

  factory AllFoodAndBeverageProduct.fromSnapshot(QuerySnapshot qs) {
    List<FoodAndBeverageProduct> FoodAndBeverageProducts;

    FoodAndBeverageProducts = qs.docs.map((DocumentSnapshot ds) {
      FoodAndBeverageProduct foodandbeverageproduct =
          FoodAndBeverageProduct.fromJson(ds.data() as Map<String, dynamic>);
      foodandbeverageproduct.id = ds.id;
      return foodandbeverageproduct;
    }).toList();

    return AllFoodAndBeverageProduct(FoodAndBeverageProducts);
  }
}
