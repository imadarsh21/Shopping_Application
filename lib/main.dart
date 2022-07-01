import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static Map<int, Color> color1 = {
    50: const Color.fromRGBO(220, 20, 60, .1),
    100: const Color.fromRGBO(220, 20, 60, .2),
    200: const Color.fromRGBO(220, 20, 60, .3),
    300: const Color.fromRGBO(220, 20, 60, .4),
    400: const Color.fromRGBO(220, 20, 60, .5),
    500: const Color.fromRGBO(220, 20, 60, .6),
    600: const Color.fromRGBO(220, 20, 60, .7),
    700: const Color.fromRGBO(220, 20, 60, .8),
    800: const Color.fromRGBO(220, 20, 60, .9),
    900: const Color.fromRGBO(220, 20, 60, 1),
  };

  static Map<int, Color> color2 = {
    50: const Color.fromRGBO(100, 149, 237, .1),
    100: const Color.fromRGBO(100, 149, 237, .2),
    200: const Color.fromRGBO(100, 149, 237, .3),
    300: const Color.fromRGBO(100, 149, 237, 0.4),
    400: const Color.fromRGBO(100, 149, 237, .5),
    500: const Color.fromRGBO(100, 149, 237, .6),
    600: const Color.fromRGBO(100, 149, 237, .7),
    700: const Color.fromRGBO(100, 149, 237, 0.8),
    800: const Color.fromRGBO(100, 149, 237, .9),
    900: const Color.fromRGBO(100, 149, 237, 1),
  };

  static MaterialColor colorCustom1 = MaterialColor(0xFFDC143C, color1);
  static MaterialColor colorCustom2 = MaterialColor(0xFF6495ED, color2);
  static MaterialColor colorCustom3 = MaterialColor(0xFF0000, color2);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //MultiProviders gives us option to include multiple providers at our root level
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products("", "", []),
            update: (ctx, auth, previousProducts) => Products(
                auth.token ?? "",
                auth.userId ?? "",
                previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders("", "", []),
            update: (ctx, ordersData, previousOrders) => Orders(
                ordersData.token ?? "",
                ordersData.userId ?? "",
                previousOrders == null ? [] : previousOrders.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, child) => MaterialApp(
            title: 'MyShop',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: "Georama",
              colorScheme: ColorScheme.fromSwatch(primarySwatch: colorCustom2)
                  .copyWith(secondary: colorCustom1),
              appBarTheme: AppBarTheme(
                  backgroundColor: colorCustom2,
                  iconTheme: const IconThemeData(color: Colors.black87),
                  titleTextStyle:
                      const TextStyle(color: Colors.black87, fontSize: 19)),
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.black54,
                selectionColor: Colors.black54,
                selectionHandleColor: Colors.black54,
              ),
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }),
            ),
            home: auth.isAuth
                ? const ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? const SplashScreen()
                            : const AuthScreen(),
                  ),
            //: authResultSnapshot.data == true? ProductsOverviewScreen()
            //it a Map<String, Widget Function(BuildContext context)> type.
            routes: {
              ProductDetailScreen.routeName: (ctx) =>
                  const ProductDetailScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrderScreen.namedRoute: (ctx) => const OrderScreen(),
              UserProductScreen.namedRoute: (ctx) => const UserProductScreen(),
              EditProductScreen.namedRoute: (ctx) => const EditProductScreen(),
            },
          ),
        ));
  }
}

//we use providers and listeners so that we don't have to pass data via arguments to different class where we directly
//don't actually need the data but instead it is need for the child or may be further.
//Also when we use providers and listeners, we don't need to refresh the whole application while changing the
//state of a certain widget but now because of providers and listeners it will only refresh the concerned
//widget where the data needs to be changed as it directly accesses the data from the provider.

//use ChangeNotifierProvider normally with "create" argument when you are providing a new instance of a class
//i.e., when you are instantiating a class BUT when you are providing a pre made object then you should use
//ChangeNotifierProvider.value normally with its "value" argument.
