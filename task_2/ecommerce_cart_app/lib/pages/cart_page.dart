import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import 'address_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController discountController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider =
      Provider.of<CartProvider>(context,
          listen: false);

      if (provider.cartItems.isEmpty) {
        provider.addToCart(
          CartItem(
            id: '1',
            name: 'Nike Shoes',
            price: 50,
          ),
        );

        provider.addToCart(
          CartItem(
            id: '2',
            name: 'T-Shirt',
            price: 30,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: provider.cartItems.length,
                itemBuilder: (context, index) {
                  final item = provider.cartItems[index];

                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '\$${item.price}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              provider.decrementQuantity(
                                  item.id);
                            },
                            icon:
                            const Icon(Icons.remove),
                          ),
                          Text(
                            item.quantity.toString(),
                          ),
                          IconButton(
                            onPressed: () {
                              provider.incrementQuantity(
                                  item.id);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: discountController,
              decoration: const InputDecoration(
                hintText: 'Enter Discount Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                provider.applyDiscountCode(
                  discountController.text,
                );
              },
              child: const Text('Apply Discount'),
            ),
            const SizedBox(height: 20),
            Text(
              'Subtotal: \$${provider.subtotal.toStringAsFixed(2)}',
            ),
            Text(
              'Tax (10%): \$${provider.tax.toStringAsFixed(2)}',
            ),
            Text(
              'Shipping: \$${provider.shippingFee}',
            ),
            Text(
              'Discount: \$${provider.discount}',
            ),
            const Divider(),
            Text(
              'Total: \$${provider.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AddressPage(),
                    ),
                  );
                },
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
