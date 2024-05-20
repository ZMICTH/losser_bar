import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/bill_order_model.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/controllers/bill_order_controller.dart';
import 'package:losser_bar/Pages/provider/product_model_page.dart';
import 'package:losser_bar/Pages/services/bill_historyservice.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final BillHistoryController billHistoryController =
      BillHistoryController(BillHistoryFirebaseService());

  String tableNo = "1";
  String roundTable = "1";
  List<String> nameOrder = [];
  List<double> priceOrder = [];
  List<int> quantity = [];
  double totalPrice = 0.0;
  double totalQuantity = 0;
  String userId = '';
  int? value = 0;
  bool paymentStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'My Order',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Consumer<ProductModel>(
        builder: (context, model, child) {
          print("Call all model ${model.cart}");
          var cartItems =
              model.cart; // Assuming this gets the list of cart items
          if (cartItems.isEmpty) {
            return Center(
              child: Text(
                "Nothing in cart",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    print(cartItems);
                    final product = cartItems[index];

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
                                Image.network(
                                  "${product['imagePath']}",
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
                                        "${product['name']} ${product['item']} ${product['unit']} ",
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
                          const Text(
                            "Total price",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "THB ${model.getTotalPrice().toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Total items: ${Provider.of<ProductModel>(context, listen: true).getTotalQuantity()}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: performConfirmOrder,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Confirm Orders"),
                      ),
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

  void performConfirmOrder() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[600]!,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          title: Text('Confirm Orders'),
          content: Text(
              'Please proceed with payment once you have received all of your food or beverage.',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Confirm',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () async {
                try {
                  // Retrieve necessary data

                  var cart =
                      Provider.of<ProductModel>(context, listen: false).cart;
                  List<Map<String, dynamic>> billuser =
                      cart.cast<Map<String, dynamic>>();
                  totalPrice = Provider.of<ProductModel>(context, listen: false)
                      .getTotalPrice() as double;
                  totalQuantity =
                      Provider.of<ProductModel>(context, listen: false)
                          .getTotalQuantity() as double;

                  print("UserID who order $userId");

                  // Update inventory for each item in the cart
                  for (var item in billuser) {
                    await FirebaseFirestore.instance
                        .collection('food_beverage')
                        .doc(item['id'])
                        .update({
                      'quantity': FieldValue.increment(
                          -item['quantity']) // decrement stock
                    });
                  }

                  // Create BillHistory object
                  final billHistory = BillOrder(
                    tableNo: tableNo,
                    roundTable: roundTable,
                    orders: billuser,
                    totalPrice: totalPrice,
                    totalQuantity: totalQuantity,
                    userId: Provider.of<MemberUserModel>(context, listen: false)
                        .memberUser!
                        .id,
                    billingTime: DateTime.now(),
                    paymentStatus: paymentStatus,
                    userNickName:
                        Provider.of<MemberUserModel>(context, listen: false)
                            .memberUser!
                            .nicknameUser,
                  );

                  await billHistoryController.addBillHistory(billHistory);
                  print("Upload successful");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Orders successful'),
                    backgroundColor: Colors.green,
                  ));

                  // Navigate to the success page
                  Provider.of<ProductModel>(context, listen: false)
                      .clearproduct();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                } catch (e, d) {
                  // Handle error
                  print(d);
                  print('Error occurred: $e');
                  // Optionally, show a snackbar or dialog with the error message
                }
              },
            ),
          ],
        );
      },
    );
  }
}
