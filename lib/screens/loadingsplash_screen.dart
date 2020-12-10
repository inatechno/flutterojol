import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myfirstapp_flutter/screens/login_screen.dart';
import 'package:myfirstapp_flutter/screens/utama_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';

class LoadingSplashScreen extends StatelessWidget {
  static String id = "loadingsplash";
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 4,
      navigateAfterSeconds: session(context),
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

  session(BuildContext context) async {
    var duration = Duration(seconds: 3);
    return Timer(duration, () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool sesi = (preferences.getBool("sesi") ?? false);
      if (sesi) {
        Navigator.pushReplacementNamed(context, UtamaScreen.id);
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      }
    });
  }
}
