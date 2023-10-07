import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'food_menu.dart';
import 'order_food_page.dart'; // Make sure to import the correct file

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'My Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<DetailproductModel>(
        builder: (context, model, child) {
          if (model.Cart.isEmpty) {
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
          return ListView.builder(
            itemCount: model.Cart.length,
            itemBuilder: (context, index) {
              final product = model.Cart[index];
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                leading: Image.asset(
                  product[
                      'imagePath'], // Use the correct key for the image path
                  width: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  product['name'], // Use the correct key for the product name
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                trailing: Text(
                  product['price'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
