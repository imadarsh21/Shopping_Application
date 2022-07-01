import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as od;

class OrderItem extends StatefulWidget {
  const OrderItem({Key? key, required this.order}) : super(key: key);
  final od.OrderItem order;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: expanded
          ? min(widget.order.products.length * 30.0 + 110.0, 208)
          : 100,

      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "\$${widget.order.amount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 17),
              ),
              subtitle: Text(DateFormat("dd/MM/yyyy, hh:mm")
                  .format(widget.order.dateTime)),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  icon: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black87,
                  )),
            ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: expanded ? min(widget.order.products.length * 25.0 + 5.0, 103) : 0,
                child: ListView(
                  children: widget.order.products
                      .map((prod) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  prod.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "${prod.quantity}x \$${prod.price}",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                )
                              ],
                            ),
                          ))
                      .toList(),
                ),
              )
          ],
        ),
      ),
    );
  }
}
