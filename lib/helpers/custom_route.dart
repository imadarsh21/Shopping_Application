import 'package:flutter/material.dart';

class CustomRoute extends MaterialPageRoute {
  CustomRoute({WidgetBuilder? builder, RouteSettings? settings})
      : super(builder: builder!, settings: settings);

  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if(settings.name != null){
      return child;
    }
    return FadeTransition(opacity: animation, child: child,);
  }
}

// for applying transitions on all the named routes, we will need this class to be set up the use it in the pageRouteTransitionTheme

class CustomPageTransitionBuilder extends PageTransitionsBuilder{
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if(route.settings.name != null){
      return child;
    }
    return FadeTransition(opacity: animation, child: child,);
  }
}

//   keytool -genkey -v -keystore c:\Users\adars\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

// C:\"Program Files"\Android\"Android Studio"\jre\bin\keytool -genkey -v -keystore c:\Users\adars\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload