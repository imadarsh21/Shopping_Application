import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

import '../model/http_exception.dart' as exception;

//"with" is a bit like extends but it is its lite version,
// in this, you don't return the class as an instance into that inherited class
// it is called a mixin in which you just can use the methods and variables of that class
//it has weaker logical connection compared to a normal extended class
//syntax for making a mixin class is => "mixin NameOfClass {}"
class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //   'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //   'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  String? token;
  String? userId;

  Products(this.token, this.userId, this._items);

  bool showFavOnly = true;

  Product findById(String? id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favItems {
    List<Product> favItems = _items.where((prodItem) => prodItem.isFavorite)
        .toList();
    return favItems;
  }

  List<Product> get items {
    return [..._items]; //just returning the copy of our _items list
  }


  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    String filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shopapp-9e1de-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString');
    try {
      var response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      // debugPrint("here we go : $extractedData");
      if(extractedData == null){
        return;
      }

      url = Uri.parse(
          "https://shopapp-9e1de-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$token");
      final favResponse = await http.get(url);
      final Map<String, dynamic>? favResponseData = json.decode(favResponse.body);

      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(id: prodId,
            title: prodData["title"],
            isFavorite : favResponseData == null ? false : favResponseData[prodId] ?? false,
            description: prodData["description"],
            price: prodData["price"],
            imageUrl: prodData["imageUrl"]));
      });
      _items = loadedProduct;
      notifyListeners();
      // debugPrint("${json.decode(response.body)}");
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        "https://shopapp-9e1de-default-rtdb.firebaseio.com/products.json?auth=$token");

    //here you don't need to put return statement since we are using async,
    // it returns futures automatically and also wrap things written inside that async function into future
    try {
      final response = await http.post(url, body: json.encode({
        "title": product.title,
        "description": product.description,
        "imageUrl": product.imageUrl,
        // "isFavorite": product.isFavorite,
        "price" : product.price,
        "creatorId" : userId
      }));
      Product newProduct = Product(id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(
          newProduct); //adds the product at the last of the list, _items.insert(0, newProduct) will add the product item at the beginning
      notifyListeners();
    } catch (error) {
      rethrow;
    }

    // //if we don't want to use async await try catch the use the below commented out code
    // return http.post(url, body: json.encode({
    //   "title" : product.title,
    //   "description" : product.description,
    //   "imageUrl" : product.imageUrl,
    //   "isFavorite" : product.isFavorite
    // })).then((response){
    //   debugPrint(json.decode(response.body)["name"]);
    //   Product newProduct = Product(id: json.decode(response.body)["name"],
    //       title: product.title,
    //       description: product.description,
    //       price: product.price,
    //       imageUrl: product.imageUrl);
    //   _items.add(newProduct); //adds the product at the last of the list, _items.insert(0, newProduct) will add the product item at the beginning
    //   notifyListeners();
    // }).catchError((error){
    //   //this .catchError() will catch the error of any of the methods (.post() or .then())
    //   //the .then() method got skipped since the error occurred in the .post() method
    //   // and the .catchError() is being called below the .then() method that's why it got skipped
    //   throw error; //it throws an error which it got above
    // });
  }

  Future<void> updateProduct(String? productId, Product newProduct) async{
    final prodIndex = _items.indexWhere((prod) =>
    prod.id == productId); //returns index
    if (prodIndex >= 0) {
      final url = Uri.parse(
          "https://shopapp-9e1de-default-rtdb.firebaseio.com/products/$productId.json?auth=$token");
      await http.patch(url, body: json.encode({
        "title" : newProduct.title,
        "description" : newProduct.description,
        "price" : newProduct.price,
        "imageUrl" : newProduct.imageUrl
      }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      // debugPrint("index caught less than 0");
    }
  }

  Future<void> removeProduct(String productId) async{
    //here, we will use the optimistic updating
    final url = Uri.parse(
        "https://shopapp-9e1de-default-rtdb.firebaseio.com/products/$productId.json?auth=$token");
    final existingProductIndex = _items.indexWhere((prod) => prod.id == productId);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    var response = await http.delete(url);
    //this expression indicates an error in case of deleting
    if(response.statusCode >= 400){
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw exception.HttpException("Could not delete the product");
    }

    existingProduct = null; //it never executes if there is any kind of error in deleting from database


    // http.delete(url).then((response){
    //
    //   //we are intentionally creating this exception if the status code is greater
    //   // than or equal to 400 so that the control may go to the .catchError block
    //   if(response.statusCode >= 400){
    //     throw exception.HttpException("Could not delete the product");
    //   }
    //   existingProduct = null;
    // }).catchError((error){
    //   _items.insert(existingProductIndex, existingProduct!);
    //   notifyListeners();
    // });

  }
}