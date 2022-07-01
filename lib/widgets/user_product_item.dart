import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';



class UserProductItem extends StatelessWidget {
  const UserProductItem({Key? key, required this.title, required this.imageUrl, required this.id}) : super(key: key);
  final String? id;
  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    var showSnackBar = ScaffoldMessenger.of(context);
    return SizedBox(
      height: 78,
      child: Column(
        children: [
          const Divider(),
          ListTile(
            title: Text(title, style: const TextStyle(fontSize: 17)),
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(imageUrl),
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(onPressed: (){
                    Navigator.of(context).pushNamed(EditProductScreen.namedRoute, arguments: id);
                  }, icon: const Icon(Icons.edit, color: Colors.black54,)),
                  IconButton(onPressed: () async{
                    try{
                      await Provider.of<Products>(context, listen: false).removeProduct(id!);
                    }catch(error){
                      showSnackBar.showSnackBar(const SnackBar(content: Text("Deletion failed")));
                    }
                  }, icon: Icon(Icons.delete, color: Theme.of(context).errorColor,))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
