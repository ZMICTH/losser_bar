import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Cart.dart';
import 'food_menu.dart';
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
    var detailproductModel = Provider.of<DetailproductModel>(context);
    var promotions = detailproductModel.promotions;
    var products = detailproductModel.products;

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          title: Center(
            child: const Text(
              'Menu',
              style: TextStyle(fontSize: 25),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              icon: Icon(Icons.bookmark_add),
              iconSize: 30,
            ),
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
            GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  final promotion = promotions[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(product: promotion),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.asset(
                                promotion['imagePath'],
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
                                  promotion['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                ),
                                Text(
                                  'THB ' + promotion['price'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            //Food
            GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(product: product),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
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
                                  product['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                ),
                                Text(
                                  'THB ' + product['price'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                      Provider.of<DetailproductModel>(context, listen: false);
                  productModel.addToBag(product);
                },
                child: Text("Add to Cart"),
              ),
            ],
          ),
        ));
  }
}
