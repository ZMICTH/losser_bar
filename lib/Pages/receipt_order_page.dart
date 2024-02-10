import 'package:flutter/material.dart';
import 'package:losser_bar/Pages/provider/product_model_page.dart';

import 'package:provider/provider.dart';

class ReceiptOrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double taxRate = 0.07; // VAT rate
    final model = Provider.of<ProductModel>(context, listen: false);
    double totalPrice = model.getTotalPrice();
    double netPrice = totalPrice * (1 + taxRate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'ใบเสร็จรับเงิน',
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
                "ไม่มีใบเสร็จรับเงิน",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Losser Bar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: model.cart.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final product = model.cart[index];
                    return ListTile(
                      leading: Image.asset(
                        product['imagePath'],
                        width: 60,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        product['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text("Quantity: ${product['quantity']}"),
                      trailing: Text(
                        "THB ${product['price']}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "รวม",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "THB ${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ราคาสุทธิ (vat 7%)",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "THB ${netPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Implement your download functionality here
                  },
                  child: const Text(
                    'Download ใบเสร็จรับเงิน.pdf',
                    style: TextStyle(
                      color: Colors
                          .white, // Ensure this color contrasts with the button color
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary, // Updated property
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
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
