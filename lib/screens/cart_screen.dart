import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import '../widgets/cart_item.dart' as ct;
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  static String routeName = "/cart";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      "\$${cart.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme.secondary, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Theme
                        .of(context)
                        .colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  OrderButton(cart: cart),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                // shrinkWrap: true,
                itemCount: cart.itemCount,
                itemBuilder: (ctx, i) =>
                    ct.CartItem(
                        id: cart.items.values.toList()[i].id,
                        //DateTime.now()
                        productId: cart.items.keys.toList()[i],
                        //id given as the key which is same as id in the product object
                        price: cart.items.values.toList()[i].price,
                        title: cart.items.values.toList()[i].title,
                        quantity: cart.items.values.toList()[i].quantity)),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (widget.cart.totalAmount <= 0 || _isLoading) ? null : () async {
          setState(() {
            _isLoading = true;
          });
          try {
            await Provider.of<Orders>(context, listen: false)
                .addOrder(widget.cart.items.values.toList(),
                widget.cart.totalAmount);
            setState(() {
              _isLoading = false;
            });
          } catch (error) {
            await showDialog(context: context, builder: (
                context) => AlertDialog(
              title: const Text("Something went wrong"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"))
              ],));
            setState(() {
              _isLoading = false;
            });
          }

          widget.cart.clear();
        },
        child: _isLoading ? const CircularProgressIndicator() : const Text(
          "ORDER NOW", style: TextStyle(color: Colors.black87),
        ));
  }
}
