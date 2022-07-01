import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import '../widgets/products_grid.dart';

enum filterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {

  Future<void> _refreshProducts(BuildContext context) async {
    // debugPrint("Refreshing");
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
    // debugPrint("Refreshed");
  }

  bool showFavoritesOnly = false;
  bool _isInit = true;
  bool _isLoading = false;

  // @override
  // void initState() {
  //
  // // Provider.of<Products>(context)
  //     //     .fetchData();   //This won't work in initState, but it will work listen: is set to false.
  //
  //   // //To use Provider.of(context) in the init state we need to do it like this
  //   // //this will first initialise the class and widgets and then come back and execute this
  //   // Future.delayed(Duration.zero).then((_){
  //   //   Provider.of<Products>(context).fetchAndSetProducts();
  //   // });
  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
        debugPrint("isInit has been set to true");
      });
        Provider.of<Products>(context)
            .fetchAndSetProducts()
            .then((_) {
          // debugPrint("products have been accessed");
          setState(() {
            _isLoading = false;
          });
        });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Shop App",
          ),
          actions: [
            PopupMenuButton(
                onSelected: (filterOptions valueSelected) {
                  setState(() {
                    if (valueSelected == filterOptions.favorites) {
                      showFavoritesOnly = true;
                    } else {
                      showFavoritesOnly = false;
                    }
                  });
                },
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                      const PopupMenuItem(
                        child: Text("Only Favorites"),
                        value: filterOptions.favorites,
                      ),
                      const PopupMenuItem(
                        child: Text("Show All"),
                        value: filterOptions.all,
                      ),
                    ]),
            Consumer<Cart>(
              builder: (ctx, cart, ch) =>
                  Badge(child: ch!, value: cart.itemCount.toString()),
              child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, CartScreen.routeName);
                  },
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Theme.of(context).colorScheme.secondary,
                  )),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
            onRefresh: () => _refreshProducts(context),
            child: ProductsGrid(showFav: showFavoritesOnly)));
  }
}
