 
import 'package:flutter/material.dart'; 
import 'package:driverojol/screens/history_screen.dart';
import 'package:driverojol/screens/loadingsplash_screen.dart';
import 'package:driverojol/screens/login_screen.dart';
import 'package:driverojol/screens/register_screen.dart';
import 'package:driverojol/screens/utama_screen.dart'; 

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
        primarySwatch: Colors.orange,
      ),
      // home: LoadingSplashScreen(),
     
      initialRoute: LoadingSplashScreen.id,
      routes: {
        LoadingSplashScreen.id: (context) => LoadingSplashScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        UtamaScreen.id: (context) => UtamaScreen(),
        HistoryScreen.id: (context) => HistoryScreen(),
      },
    );
  }
}
