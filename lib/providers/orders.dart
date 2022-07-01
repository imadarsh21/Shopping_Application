import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }
  String? token;
  String? userId;

  Orders(this.token, this.userId, this._orders);

  Future<void> fetchAndSetOrders() async{
    var url = Uri.parse(
        "https://shopapp-9e1de-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token");
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    _orders = [];
    if(extractedData == null){
      // debugPrint("extracted data is null");
      return;
    }
    // debugPrint(" here: $extractedData");
    extractedData.forEach((orderId, orderData) {
      loadedOrders.insert(
          0,
          OrderItem(
              id: orderId,
              amount: orderData["amount"],
              dateTime: DateTime.parse(orderData["dateTime"]),
              products: (orderData["products"] as List<dynamic>)
                  .map((item) => CartItem(
                      id: item["id"],
                      title: item["title"],
                      quantity: item["quantity"],
                      price: item["price"])
              ).toList(),

              ));
    });

    _orders = loadedOrders;
    notifyListeners();


  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var timeStamp = DateTime.now();
    var url = Uri.parse(
        "https://shopapp-9e1de-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token");
    try {
      var response = await http.post(url,
          body: json.encode({
            "amount": total,
            "dateTime": timeStamp.toIso8601String(),
            "products": cartProducts
                .map((cp) => {
                      "id": cp.id,
                      "title": cp.title,
                      "quantity": cp.quantity,
                      "price": cp.price
                    })
                .toList()
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)["name"],
              amount: total,
              products: cartProducts,
              dateTime: timeStamp));
      notifyListeners();
    } catch (error) {
      rethrow;
    }

    notifyListeners();
  }
}
