import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/provider/product_model_page.dart';

import 'package:losser_bar/Pages/controllers/food_and_beverage_controller.dart';
import 'package:losser_bar/Pages/services/food_and_beverage_service.dart';

import 'package:provider/provider.dart';

class FoodandBeverageScreen extends StatefulWidget {
  @override
  State<FoodandBeverageScreen> createState() => _FoodandBeverageScreenState();
}

class _FoodandBeverageScreenState extends State<FoodandBeverageScreen> {
  late FoodAndBeverageController foodandbeveragecontroller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    foodandbeveragecontroller =
        FoodAndBeverageController(FoodAndBeverageFirebaseService());
    _loadFoodAndBeverageProducts();
  }

  Future<void> _loadFoodAndBeverageProducts() async {
    try {
      var foodProducts =
          await foodandbeveragecontroller.fetchFoodAndBeverageProduct();
      Provider.of<ProductModel>(context, listen: false)
          .setFoodAndBeverageProducts(foodProducts);
    } catch (e) {
      print('Error fetching FoodProduct: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final promotionModel = Provider.of<ProductModel>(context);
    final foodandbeverageModel = Provider.of<ProductModel>(context);

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          title: Text(
            'Menu',
            style: TextStyle(fontSize: 25),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // actions: [
          //   InkWell(
          //     onTap: () {
          //       Navigator.pushNamed(context, '/cart');
          //     },
          //     child: Stack(
          //       alignment: Alignment.center,
          //       children: [
          //         const Padding(
          //           padding: EdgeInsets.only(
          //             right: 9,
          //             top: 6,
          //           ),
          //           child: Icon(
          //             Icons.bookmark_add,
          //             // color: Theme.of(context).colorScheme.onPrimary,
          //           ),
          //         ),
          //         if (promotionModel.cart.length > 0)
          //           Positioned(
          //             top: 4.0,
          //             right: 4.0,
          //             child: CircleAvatar(
          //               radius: 8.0,
          //               backgroundColor:
          //                   Theme.of(context).colorScheme.secondary,
          //               child: Text(
          //                 '${promotionModel.cart.length}',
          //                 style: const TextStyle(
          //                   fontSize: 12.0,
          //                   color: Colors.white,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //             ),
          //           ),
          //       ],
          //     ),
          //   ),
          //   const SizedBox(width: 10),
          // ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(
                  Icons.sell,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.fastfood,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Promotion tab
                  _buildPromotionTab(promotionModel),
                  // Other tabs...
                  _buildFoodAndBeverageTab(foodandbeverageModel),
                ],
              ),
      ),
    );
  }

  Widget _buildPromotionTab(ProductModel promotionModel) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
        mainAxisSpacing: 17,
        crossAxisSpacing: 17,
      ),
      itemCount: promotionModel.promotions.length,
      itemBuilder: (context, index) {
        final promotionProduct = promotionModel.promotions[index];
        bool isAvailable = promotionProduct.quantity > 0;
        return Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Card(
            elevation: 4, // Build your card with promotionProduct data
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      promotionProduct.foodbeverageimagePath,
                      fit: BoxFit.cover,
                      width: 90,
                      height: 100,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${promotionProduct.nameFoodBeverage} ${promotionProduct.item} ${promotionProduct.unit} THB ${promotionProduct.priceFoodBeverage}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                      if (!isAvailable)
                        Text('Item isn\'t available',
                            style: TextStyle(color: Colors.red)),
                      if (isAvailable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Add the product to the bag
                                final productModel = Provider.of<ProductModel>(
                                    context,
                                    listen: false);
                                productModel
                                    .addToCart(promotionProduct.toMap());
                              },
                              child: Text(
                                'Add To Cart',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.blueGrey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodAndBeverageTab(ProductModel foodandbeverageModel) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
        mainAxisSpacing: 17,
        crossAxisSpacing: 17,
      ),
      itemCount: foodandbeverageModel.products.length,
      itemBuilder: (context, index) {
        final foodandbeverageProduct = foodandbeverageModel.products[index];
        bool isAvailable = foodandbeverageProduct.quantity > 0;
        return Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Card(
            elevation: 10, // Build your card with promotionProduct data
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      foodandbeverageProduct.foodbeverageimagePath,
                      fit: BoxFit.cover,
                      width: 90,
                      height: 100,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${foodandbeverageProduct.nameFoodBeverage} ${foodandbeverageProduct.item} ${foodandbeverageProduct.unit} THB ${foodandbeverageProduct.priceFoodBeverage}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                      if (!isAvailable)
                        Text('Item isn\'t available',
                            style: TextStyle(color: Colors.red)),
                      if (isAvailable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Add the product to the bag
                                final productModel = Provider.of<ProductModel>(
                                    context,
                                    listen: false);
                                productModel
                                    .addToCart(foodandbeverageProduct.toMap());
                              },
                              child: Text(
                                'Add To Cart',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.blueGrey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
