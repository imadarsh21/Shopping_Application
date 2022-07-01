import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  const CartItem(
      {Key? key,
        required this.price,
        required this.title,
        required this.quantity,
        required this.id,
        required this.productId})
      : super(key: key);
  final String id;
  final String productId;
  final double price;
  final String title;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        alignment: Alignment.centerRight,
        color: Theme.of(context).errorColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.delete, size: 30, color: Theme.of(context).primaryColorLight,),
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction){
        return showDialog(context: context, builder: (ctx){
          return AlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("Do you really want to remove this item from your cart?"),
            actions: [
              TextButton(onPressed: (){
                Navigator.of(context).pop(false); //return false so that confirmDismiss get the false and does not delete the element
              }, child: const Text("No")),
              TextButton(onPressed: (){
                Navigator.of(context).pop(true); //return true so that confirmDismiss get the true and delete the element
              }, child: const Text("Yes"))
            ],
          );
        });
      },
      onDismissed: (direction){
        Provider.of<Cart>(context, listen: false).removeItems(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            radius: 23,
            child: FittedBox(child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text("\$$price", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),),
            )),
          ),
          title: Text(title),
          subtitle: Text("\$${(price * quantity)}"),
          trailing: Text("$quantity x"),
        ),
      ),
    );
  }
}
