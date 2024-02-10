import 'dart:async';

import 'package:losser_bar/Pages/Model/mate_model.dart';
import 'package:losser_bar/Pages/services/mate_service.dart';

class MateCatalogController {
  List<MateCatalog> MateCatalogs = List.empty();
  final MateCatalogService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  MateCatalogController(this.service);

  Future<List<MateCatalog>> fetchMateCatalog() async {
    print("fetchMateCatalog was: ${MateCatalogs}");
    onSyncController.add(true);
    MateCatalogs = await service.getAllMateCatalog();
    onSyncController.add(false);
    return MateCatalogs;
  }

  // void updateFoodAndBeverageProduct(
  //     FoodAndBeverageProduct foodandbeverageproduct) async {
  //   service.updateFoodAndBeverageProduct(foodandbeverageproduct);
  // }
}
