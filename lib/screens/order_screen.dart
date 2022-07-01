import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import '../widgets/order_item.dart' as ord;

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);
  static String namedRoute = "/order-screen";

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  //this _ordersFuture and _obtainOrdersFuture is being made outside
  // the build so that if build needs to run many times, it doesn't run
  // the future inside the future builder which can now only be run one
  // time while starting this order screen

  Future? _ordersFuture;

  Future<void> _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  // @override
  // void dispose() {
  //   void run() async{
  //     var kala = await _ordersFuture;
  //     kala.depose();
  //   }
  //   super.dispose();
  // }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Something went wrong...",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                );
              }
              // debugPrint("snapshot.data is ${snapshot.data}");
              return Consumer<Orders>(builder: (ctx, orderData, child) {
                // debugPrint("we are inside consumer going to build the list view after checking for
                // length of our order list ${orderData.orders} and length is ${orderData.orders.length}");
                if (orderData.orders.length == 0) {
                  return Center(child: Text("Please order something...", style: TextStyle(fontSize: 16.5),));
                } else {
                  return ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, i) => ord.OrderItem(
                            order: orderData.orders[i],
                          ));
                }
              });
            }
          }),
    );
  }
}

// //this is the approach in which you don't need future builder but above code block looks more elegant
// class OrderScreen extends StatefulWidget {
//   const OrderScreen({Key? key}) : super(key: key);
//   static String namedRoute = "/order-screen";
//
//   @override
//   State<OrderScreen> createState() => _OrderScreenState();
// }
//
// class _OrderScreenState extends State<OrderScreen> {
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//
//     //Although the duration has been set to zero, dart by default give this future its time
//     // and then come back to execute it till then we will have our context set up.
//     Future.delayed(Duration.zero).then((_) async{
//       setState(() {
//         _isLoading = true;
//       });
//       await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
//       setState(() {
//         _isLoading = false;
//       });
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var orderData = Provider.of<Orders>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Orders"),
//       ),
//       drawer: const AppDrawer(),
//       body: _isLoading ? const Center(child: CircularProgressIndicator(),) : ListView.builder(
//           itemCount: orderData.orders.length,
//           itemBuilder: (ctx, i) => ord.OrderItem(order: orderData.orders[i],)),
//     );
//   }
// }
