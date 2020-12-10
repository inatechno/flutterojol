import 'package:flutter/material.dart';
import 'package:myfirstapp_flutter/screens/loadingsplash_screen.dart';
import 'package:myfirstapp_flutter/screens/login_screen.dart';
import 'package:myfirstapp_flutter/screens/register_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoadingSplashScreen(),
    );
  }
}

