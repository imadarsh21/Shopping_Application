import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false
  });

  void toggleFavStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners(); //it notifies the listeners and then changes the state, kinda like setState of stateful widget

    final url = Uri.parse(
        "https://shopapp-9e1de-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token");
    try {
      final response = await http.put(url, body: json.encode(
          isFavorite
      ));
      if(response.statusCode >= 400){
        isFavorite = oldStatus;
        notifyListeners();
      }
    }

    //unlike .get and .post, http doesn't throw an error for patch, delete and put
    //so this won't run but it may run in case of network error or something
    //so for the safe side this block will also be kept inside the code
    catch(error){
      isFavorite = oldStatus;
      notifyListeners();
    }
  }



}