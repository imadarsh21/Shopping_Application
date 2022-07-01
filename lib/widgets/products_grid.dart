import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFav;
  const ProductsGrid({Key? key, required this.showFav}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //here we getting an instance of Products class assigned to productsData
    final productsData = Provider.of<Products>(context);
    final List<Product> products = showFav ? productsData.favItems : productsData.items;
    return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0),
        itemBuilder: (ctx, i) {
          return ChangeNotifierProvider.value( //reference to the comment section in main.dart file to know more
            value: products[i],
            child: ProductItem()
          );});
  }
}
