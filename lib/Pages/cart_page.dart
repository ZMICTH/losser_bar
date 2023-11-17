import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Model/product_model_page.dart';

//merage item and delete ist

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'My Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ProductModel>(
        builder: (context, model, child) {
          if (model.cart.isEmpty) {
            return Center(
              child: Text(
                "Nothing in cart",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: model.cart.length,
                  itemBuilder: (context, index) {
                    final product = model.cart[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Image.asset(
                                  product[
                                      'imagePath'], // Use the correct key for the image path
                                  width: 60,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] +
                                            " ${product['item']} " +
                                            "${product['unit']} ", // Use the correct key for the product name
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "THB ${product['price']}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          // Text('fill count item'),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                final productModel =
                                                    Provider.of<ProductModel>(
                                                        context,
                                                        listen: false);
                                                productModel
                                                    .decreaseQuantity(product);
                                              },
                                              child: const Icon(
                                                Icons.remove,
                                                size: 30,
                                              ),
                                            ),
                                            Text(
                                              "${product['quantity']}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                final productModel =
                                                    Provider.of<ProductModel>(
                                                        context,
                                                        listen: false);
                                                productModel
                                                    .increaseQuantity(product);
                                              },
                                              child: const Icon(
                                                Icons.add,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        final productModel =
                                            Provider.of<ProductModel>(context,
                                                listen: false);
                                        productModel.removeFromCart(product);
                                      },
                                      child: const Icon(
                                        Icons.delete_forever,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              //total prices
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text("Total price"),
                          const SizedBox(
                            height: 2,
                          ),
                          Consumer<ProductModel>(
                            builder: (context, productModel, child) {
                              return Text(
                                  "THB ${productModel.getTotalPrice().toStringAsFixed(2)}");
                            },
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // backgroundColor:
                          //     Theme.of(context).colorScheme.inversePrimary,
                          textStyle: TextStyle(
                            fontSize: 20, // Text size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Pay Now"),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //       border: Border.all(color: Colors.white),
                      //       borderRadius: BorderRadius.circular(12)),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Row(
                      //       children: [
                      //         Text("Pay Now "),
                      //         Icon(
                      //           Icons.arrow_forward_ios,
                      //           size: 16,
                      //           color: Colors.white,
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
