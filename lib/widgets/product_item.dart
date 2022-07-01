import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context,
        listen: false); //This builds up the whole build function in which it
    // stays in but if you want it to just receive certain fixed values and doesn't want it to get changed
    //then you can set the listen to false which will not listen to any changes occurring inside the provider
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: GridTile(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
            child: Hero(
              tag: product.id.toString(),
              child: FadeInImage(
                  placeholder:
                      const AssetImage("assets/images/web_hi_res_512.png"),
                  image: NetworkImage(product.imageUrl), fit: BoxFit.cover,),
            )),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(product.title),
          trailing: IconButton(
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Item added successfully"),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ));
              },
              icon: Icon(
                Icons.add_shopping_cart,
                color: Theme.of(context).colorScheme.secondary,
              )),
          //We can wrap up a widget in which we want to use data from provider and change
          // the state on the screen with Consumer widget specifying the type we expect.
          //In the Consumer widget will receive three arguments in which the child argument
          //gives us the opportunity to define a child and the use it inside the IconButton
          //this child will not be affected by the changes occurring inside the provider
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              onPressed: () {
                product.toggleFavStatus(authData.token!, authData.userId!);
              },
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            child: const Text(
                "Any widget you want to put inside this Consumer widget which doesn't need to get affected by the changes"),
          ),
        ),
      ),
    );
  }
}
