import 'package:flutter/material.dart';
import 'package:provider/provider.dart';import 'package:shop_app/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight:  300,
            backgroundColor: Colors.white,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title, style: TextStyle(color: Colors.grey.shade900),),
              background: Hero(
                  tag: loadedProduct.id.toString(),
                  child: Image.network(
                    loadedProduct.imageUrl,
                    fit: BoxFit.cover,
                  )),
            ),
          ), SliverList(

              delegate: SliverChildListDelegate([
            // SizedBox(
            //     height: 300.0,
            //     width: MediaQuery.of(context).size.width,
            //     child:
            // ),
            const SizedBox(
              height: 25.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.5),
              child: SizedBox(
                child: Text(
                  loadedProduct.title,
                  style: const TextStyle(fontFamily: "Georama-Bold", fontSize: 22),
                ),
              ),
            ),
            const SizedBox(
              height: 7.5,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.5),
              child: Divider(
                height: 4.0,
                color: Colors.black87,
                thickness: 0.5,
              ),
            ),
            const SizedBox(
              height: 7.5,
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                    "Description: ",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10,),
                  Text(loadedProduct.description, style: const TextStyle(fontSize: 17.2),)
                  ]
                ),
              ),
            ),
            const SizedBox(height: 1000,)
          ]))
        ],
      )

    );
  }
}
