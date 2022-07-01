// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/model/http_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(100, 149, 237, 0.6),
              // gradient: LinearGradient(
              //   colors: [
              //     // Color.fromRGBO(238, 130, 238, 0.5),
              //     // Color.fromRGBO(220, 20, 60, 0.2),
              //     Color.fromRGBO(100, 149, 237, 0.9),
              //     // Color.fromRGBO(220, 20, 60, 0.65),
              //     // Color.fromRGBO(1,1,1, 1.0),
              //
              //
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   // stops: [0.9,0.7],
              // ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 10.0),
                      //     // // for rotating along z-axis
                      //     // transform: Matrix4.rotationZ(-8 * pi / 180)
                      //     //   ..translate(-10.0),
                      //     // ..translate(-10.0),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(20),
                      //       color: Colors.deepOrange.shade900,
                      //       boxShadow: const [
                      //         BoxShadow(
                      //           blurRadius: 8,
                      //           color: Colors.black26,
                      //           offset: Offset(0, 2),
                      //         )
                      //       ],
                      //     ),
                      child: const Text(
                        'Shop App',
                        style: TextStyle(
                          // color: Color.fromRGBO(220, 20, 60, 1),
                          color: Colors.black54,
                          fontSize: 40,
                          fontFamily: 'Georama',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.signup;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  AnimationController? _controller;
  Animation<Size>? _heightAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _heightAnimation = Tween<Size>(
            begin: const Size(double.infinity, 420),
            end: const Size(double.infinity, 320))
        .animate(
            CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn));
    // _heightAnimation!.addListener(() {setState(() {});});
    // we don't really need to do this manually if we are using AnimatedBuilder to construct the widget we want to animate
    _opacityAnimation = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("An error occurred"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .login(_authData["email"]!, _authData["password"]!);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData["email"]!, _authData["password"]!);
      }
    } on HttpException catch (error) {
      var errorMessage = "Authentication Failed";
      if (error.message.toString().contains("EMAIL_EXIST")) {
        errorMessage = "This email is already in use";
      } else if (error.message.toString().contains("INVALID_EMAIL")) {
        errorMessage = "This is not a valid email address";
      } else if (error.message.toString().contains("WEAK_PASSWORD")) {
        errorMessage = "Password is too short";
      } else if (error.message.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "This email does not exist";
      } else if (error.message.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Invalid password";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = "Could not authenticate you. Please try again later";
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.signup) {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller!.forward();
    } else {
      setState(() {
        _authMode = AuthMode.signup;
      });
      _controller!.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    //we can also use animated container here as we are ony going to animate a single container
    return AnimatedBuilder(
      animation: _heightAnimation!,
      builder: (ctx, ch) => Container(
        // height: _authMode == AuthMode.signup ? 340 : 260,
        height: _heightAnimation!.value.height,
        constraints: BoxConstraints(minHeight: _heightAnimation!.value.height),
        //_authMode == AuthMode.signup ? 340 : 260),
        width: deviceSize.width * 0.85,
        padding: const EdgeInsets.all(16.0),
        child: ch,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: TextStyle(color: Colors.black54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0,0,0, 0.75)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0,0,0, 0.85)),
                  ),
                  // border: UnderlineInputBorder(
                  //   borderSide: BorderSide(color: Color.fromRGBO(220,20,60, 1)),
                  // ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['email'] = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0,0,0, 0.75)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0,0,0, 0.85)),
                  ),
                ),
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['password'] = value!;
                },
              ),
              // if (_authMode == AuthMode.signup)
              AnimatedContainer(
                constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.signup ? 120 : 0),
                duration: const Duration(milliseconds: 400),
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: TextFormField(
                    enabled: _authMode == AuthMode.signup,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.black54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(0,0,0, 0.75)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(0,0,0, 0.85)),
                      ),
                    ),
                    obscureText: true,
                    validator: _authMode == AuthMode.signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 2.0),
                  child: ElevatedButton(
                    child: Text(
                      _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP',
                      style: TextStyle(
                        // color: Theme.of(context).primaryTextTheme.button!.color,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      // primary: const Color.fromRGBO(220, 20, 60, 1),
                      primary: Colors.black38,
                    ),
                    onPressed: _submit,
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 2),
                child: TextButton(
                  child: Text(
                    '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color.fromRGBO(0,0,0, 0.8)),
                  ),
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _switchAuthMode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
