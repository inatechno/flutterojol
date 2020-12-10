import 'package:flutter/material.dart';
import 'package:myfirstapp_flutter/screens/login_screen.dart';
import 'package:splashscreen/splashscreen.dart';

class LoadingSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 4,
      navigateAfterSeconds: LoginScreen(),
      title: Text(
        'Welcome In Flutter OJOL',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      image: Image.asset(
        "images/ina.png",
        color: Colors.orange[900],
      ),
      loadingText: Text("tunggu ya..."),
      backgroundColor: Colors.white,
      photoSize: 130,
      loaderColor: Colors.orange[900],
    );
  }
}
