import 'package:flutter/material.dart';
import 'Model/product_model_page.dart';
import 'package:provider/provider.dart';

class TabBarApp extends StatelessWidget {
  const TabBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class OrderFoodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var detailproductModel = Provider.of<ProductModel>(context);
    var promotions = detailproductModel.promotions;
    var products = detailproductModel.products;

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          title: const Center(
            child: Text(
              'Menu',
              style: TextStyle(fontSize: 25),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      right: 9,
                      top: 6,
                    ),
                    child: Icon(
                      Icons.bookmark_add,
                      // color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  if (detailproductModel.cart.length > 0)
                    Positioned(
                      top: 4.0,
                      right: 4.0,
                      child: CircleAvatar(
                        radius: 8.0,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: Text(
                          '${detailproductModel.cart.length}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(
                  Icons.sell,
                  size: 30,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.fastfood,
                  size: 30,
                ),
              ),
              // Tab(
              //   icon: Icon(Icons.emoji_food_beverage_outlined),
              // ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            //Promotion
            GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.5,
                  mainAxisSpacing: 17,
                  crossAxisSpacing: 17,
                ),
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  final promotion = promotions[index];
                  return Card(
                    elevation: 4,
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
                            child: Image.asset(
                              promotion['imagePath'],
                              fit: BoxFit.cover,
                              width: 100,
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
                                promotion['name'] +
                                    " ${promotion['item']} " +
                                    "${promotion['unit']} " +
                                    'THB ' +
                                    "${promotion['price']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        // Add the product to the bag
                                        final productModel =
                                            Provider.of<ProductModel>(context,
                                                listen: false);
                                        productModel.addToCart(promotion);
                                      },
                                      child: Text(
                                        'Add To Cart',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.blueGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            //Food
            GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    elevation: 4,
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
                            child: Image.asset(
                              product['imagePath'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] +
                                    " ${product['item']} " +
                                    "${product['unit']} " +
                                    'THB ' +
                                    "${product['price']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        // Add the product to the bag
                                        final productModel =
                                            Provider.of<ProductModel>(context,
                                                listen: false);
                                        productModel.addToCart(product);
                                      },
                                      child: Text(
                                        'Add To Cart',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.blueGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            product['name'],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                width: 200,
                child: Image.asset(product['imagePath']),
              ),
              Text(
                product['name'],
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add the product to the bag
                  final productModel =
                      Provider.of<ProductModel>(context, listen: false);
                  productModel.addToCart(product);
                },
                child: const Text("Add to Cart"),
              ),
            ],
          ),
        ));
  }
}
