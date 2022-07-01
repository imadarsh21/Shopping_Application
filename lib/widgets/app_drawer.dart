import 'package:flutter/material.dart';
import 'package:shop_app/screens/order_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text("Hello Friend!"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black87,),
            title: const Text("Shop", style: TextStyle(fontSize: 17),),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/"); //predefined to go to the home page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.book_rounded, color: Colors.black87),
            title: const Text("Your Orders", style: TextStyle(fontSize: 17)),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(OrderScreen.namedRoute);
              //if you want to build custom routes for some of the routes use this way other wise see the main.dart at the pageTransitionTheme section in themes:
              // Navigator.of(context).pushReplacement(CustomRoute(builder: (context) => const OrderScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.black87),
            title: const Text("Manage Products", style: TextStyle(fontSize: 17)),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(UserProductScreen.namedRoute);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.black87),
            title: const Text("Logout", style: TextStyle(fontSize: 17)),
            onTap: (){
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/");
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
