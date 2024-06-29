import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/Model/bill_order_model.dart';
import 'package:losser_bar/Pages/Model/login_model.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:losser_bar/Pages/controllers/bill_order_controller.dart';
import 'package:losser_bar/Pages/controllers/reserve_table_controller.dart';
import 'package:losser_bar/Pages/provider/product_model_page.dart';
import 'package:losser_bar/Pages/services/bill_historyservice.dart';
import 'package:losser_bar/Pages/services/reserve_table_service.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(ReserveTableFirebaseService());
  bool isLoading = true;

  final BillHistoryController billHistoryController =
      BillHistoryController(BillHistoryFirebaseService());

  @override
  void initState() {
    super.initState();
    reservetablehistorycontroller =
        ReserveTableHistoryController(ReserveTableFirebaseService());
    _loadReservationHistory();
  }

  Future<void> _loadReservationHistory() async {
    setState(() => isLoading = true);
    try {
      List<ReserveTableHistory> fetchedReservations =
          await reservetablehistorycontroller.fetchReserveTableHistory();
      Provider.of<ReserveTableProvider>(context, listen: false)
          .setTableNo(fetchedReservations);
      Provider.of<ReserveTableProvider>(context, listen: false)
          .filterCheckedInToday(context);

      // Check if there is any valid table number
      var reserveTableProvider =
          Provider.of<ReserveTableProvider>(context, listen: false);
      if (reserveTableProvider.allReserveTable.isEmpty) {
        _showNoTableAlertDialog();
      }
    } catch (e) {
      print('Error fetching reservation history: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showNoTableAlertDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false, // Prevents dismissing by back button
            child: AlertDialog(
              title: Text(
                "No Table Booked",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              content: Text(
                  "You haven't checked in yet or you haven't booked a table for today."),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Consumer<ReserveTableProvider>(
          builder: (context, reserveTableProvider, child) {
            String tableNo = "No Table";
            if (reserveTableProvider.allReserveTable.isNotEmpty) {
              tableNo = reserveTableProvider.allReserveTable.first.tableNo!;
              print("table filter: ${tableNo}");
              print(
                  "table filter: ${reserveTableProvider.allReserveTable.first.id}");
              print(
                  "table filter: ${reserveTableProvider.allReserveTable.first.partnerId}");
            }
            return Text(
              'Table No. $tableNo',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              //Move between page
              Navigator.pushNamed(context, '');
            },
            icon: const Icon(Icons.person_add),
            iconSize: 30,
            color: Theme.of(context).colorScheme.background,
          ),
          SizedBox(width: 35),
          IconButton(
            onPressed: () {
              //Move between page
              Navigator.pushNamed(context, '/3');
            },
            icon: const Icon(Icons.add_shopping_cart),
            iconSize: 30,
            color: Theme.of(context).colorScheme.background,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<ProductModel>(
              builder: (context, model, child) {
                var cartItems = model.cart;
                if (cartItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Nothing in cart",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/3');
                          },
                          child: Text('Add Orders'),
                        )
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final product = cartItems[index];
                          return CartItemCard(product: product);
                        },
                      ),
                    ),
                    CartSummary(
                      totalPrice: model.getTotalPrice(),
                      totalQuantity: model.getTotalQuantity(),
                      onConfirmOrder: performConfirmOrder,
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
        return ConfirmOrderDialog(
          onConfirm: () async {
            try {
              var cart = Provider.of<ProductModel>(context, listen: false).cart;
              List<Map<String, dynamic>> billuser =
                  cart.cast<Map<String, dynamic>>();
              double totalPrice =
                  Provider.of<ProductModel>(context, listen: false)
                      .getTotalPrice();
              double totalQuantity =
                  Provider.of<ProductModel>(context, listen: false)
                      .getTotalQuantity();

              var reserveTableProvider =
                  Provider.of<ReserveTableProvider>(context, listen: false);
              final partnerId =
                  reserveTableProvider.allReserveTable.first.partnerId;

              for (var item in billuser) {
                await FirebaseFirestore.instance
                    .collection('food_beverage')
                    .doc(item['id'])
                    .update({
                  'quantity': FieldValue.increment(-item['quantity']),
                });
              }

              final newOrder = BillOrder(
                orders: billuser,
                totalPrice: totalPrice,
                totalQuantity: totalQuantity,
                partnerId: partnerId,
                billingTime: DateTime.now(),
                paymentStatus: false,
                userNickName:
                    Provider.of<MemberUserModel>(context, listen: false)
                        .memberUser!
                        .nicknameUser,
                tableNo: reserveTableProvider.allReserveTable.first.tableNo!,
                roundtable:
                    reserveTableProvider.allReserveTable.first.roundtable!,
              );

              await billHistoryController.addBillHistory(newOrder);

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Orders successful'),
                backgroundColor: Colors.green,
              ));

              Provider.of<ProductModel>(context, listen: false).clearproduct();
              Navigator.popUntil(context, (route) => route.isFirst);
            } catch (e, d) {
              print('Error occurred: $e');
              print(d);
            }
          },
        );
      },
    );
  }
}

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const CartItemCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  product['imagePath'],
                  width: 60,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${product['name']} ${product['item']} ${product['unit']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "THB ${product['price']}",
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                Provider.of<ProductModel>(context,
                                        listen: false)
                                    .decreaseQuantity(product);
                              },
                              child: const Icon(Icons.remove, size: 30),
                            ),
                            Text(
                              "${product['quantity']}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Provider.of<ProductModel>(context,
                                        listen: false)
                                    .increaseQuantity(product);
                              },
                              child: const Icon(Icons.add, size: 30),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                InkWell(
                  onTap: () {
                    Provider.of<ProductModel>(context, listen: false)
                        .removeFromCart(product);
                  },
                  child: const Icon(Icons.delete_forever, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final double totalPrice;
  final double totalQuantity;
  final VoidCallback onConfirmOrder;

  const CartSummary({
    Key? key,
    required this.totalPrice,
    required this.totalQuantity,
    required this.onConfirmOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Text("Total prices",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )),
                const SizedBox(height: 2),
                Text(
                  "THB ${totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Total items: ${totalQuantity.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: onConfirmOrder,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirm Orders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmOrderDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmOrderDialog({Key? key, required this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blueGrey[600]!,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      title: Text('Confirm Orders'),
      content: Text(
        'Please proceed with payment once you have received all of your food or beverage.',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Confirm',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: onConfirm,
        ),
      ],
    );
  }
}
