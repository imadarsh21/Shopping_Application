import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);
  static String namedRoute = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  bool _isLoading = false;
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final TextEditingController _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');

  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };

  var _isInit = true;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_imageUpdateUrl);
    super.initState();
  }

  //This also run before the build runs, you cannot receive arguments in the init so we will receive it here
  //since this override runs multiple time during the app building we will play a trick to ensure that we receive the value only once
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      // debugPrint("inside override");
      if (productId != null) {
        // debugPrint("inside editing");
        _editedProduct =
            Provider.of<Products>(context).findById(productId.toString());
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  //this override helps us to dispose the value stored in memory when not in use
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_imageUpdateUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _imageUpdateUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith("jpg") &&
              !_imageUrlController.text.endsWith("jpeg") &&
              !_imageUrlController.text.endsWith("png"))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState!.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id == null) {
      // debugPrint("inside add product");

      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text("An error occurred."),
                  content: const Text("Something went wrong."),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text("OK"))
                  ],
                ));
      }

      // finally{
      //   setState(() {
      //     _isLoading = false;
      //     Navigator.of(context).pop();
      //   });
      // }

      // //if we don't want to use async await try catch the use the below commented out code
      // Provider.of<Products>(context, listen: false).addProduct(_editedProduct)
      //     .catchError((error){
      //       return showDialog<Null>(context: context, builder: (ctx) => AlertDialog(
      //         title: const Text("An error occurred."),
      //         content: const Text("Something went wrong."),
      //           actions: [
      //             TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK"))
      //           ],
      //       ));
      // })
      // //.then() is executed when the future gets resolved either normally or by handling its error
      //     .then((_){
      //   setState(() {
      //     _isLoading = false;
      //     Navigator.of(context).pop();
      //   });
      // });
    } else {
      // debugPrint("inside update product");
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    }

    setState(() {
      _isLoading = false;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _editedProduct.id == null ? const Text("Add Product ") : const Text("Edit Product"),
        actions: [
          IconButton(onPressed: () => _saveForm(), icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Title",
                          labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Color.fromRGBO(0,0,0, 0.75)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Color.fromRGBO(0,0,0, 0.85)),
                        ),),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      initialValue: _initValues["title"],
                      validator: (data) {
                        if (data!.isEmpty) {
                          return "Please enter the title";
                        }
                        //in validator returning null means everything is good and returning
                        // a string means there's some problem so show the returned text on the screen as an error
                        return null;
                      },
                      onSaved: (value) => _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: value!,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Price",
                          labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Color.fromRGBO(0,0,0, 0.75)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Color.fromRGBO(0,0,0, 0.85)),
                        ),),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      initialValue: _initValues["price"],
                      validator: (data) {
                        if (data!.isEmpty) {
                          return "Please enter the price";
                        }
                        if (double.tryParse(data) == null) {
                          return "Please enter a valid number";
                        }
                        if (double.parse(data) <= 0) {
                          return "Please enter a price greater than zero";
                        }
                        return null;
                      },
                      onSaved: (value) => _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value!),
                          imageUrl: _editedProduct.imageUrl),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Description",
                          labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Color.fromRGBO(0,0,0, 0.75)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Color.fromRGBO(0,0,0, 0.85)),
                        ),),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      initialValue: _initValues["description"],
                      validator: (data) {
                        if (data!.isEmpty) {
                          return "Please enter a description";
                        }
                        if (data.length < 10) {
                          return "Should be at least 10 characters long";
                        }
                        return null;
                      },
                      onSaved: (value) => _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: value!,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl),
                    ),
                    SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 80,
                              margin: const EdgeInsetsDirectional.only(
                                  top: 8.0, end: 8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  )),
                              child: _imageUrlController.text.isEmpty
                                  ? const Center(child: Text("Enter Url"))
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Image Url",
                                  labelStyle: TextStyle(color: Colors.black54),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color.fromRGBO(0,0,0, 0.75)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color.fromRGBO(0,0,0, 0.85)),
                                ),),
                              maxLines: 2,
                              keyboardType: TextInputType.url,
                              textInputAction: inputAction(),
                              controller: _imageUrlController,
                              //we put this so that we have access to the entered text even before the contents of the form has been submitted
                              focusNode: _imageUrlFocusNode,

                              validator: (data) {
                                if (data!.isEmpty) {
                                  return "Please enter an Image URL";
                                }
                                if (!data.startsWith("http") &&
                                    !data.startsWith("https")) {
                                  return "Please enter a valid Image URL";
                                }
                                if (!data.endsWith("png") &&
                                    !data.endsWith("jpg") &&
                                    !data.endsWith("jpeg")) {
                                  return "Please enter a valid image URL";
                                }
                                return null;
                              },

                              onFieldSubmitted: (_) => _saveForm(),
                              onSaved: (value) => _editedProduct = Product(
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: value!),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  inputAction() {
    setState(() {
      TextInputAction.done;
    });
  }
}
