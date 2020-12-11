import 'package:flutter/material.dart';
import 'package:myfirstapp_flutter/screens/goride_screen.dart';
import 'package:myfirstapp_flutter/screens/history_screen.dart';
import 'package:myfirstapp_flutter/screens/loadingsplash_screen.dart';
import 'package:myfirstapp_flutter/screens/login_screen.dart';
import 'package:myfirstapp_flutter/screens/register_screen.dart';
import 'package:myfirstapp_flutter/screens/utama_screen.dart';
import 'package:myfirstapp_flutter/screens/waitingdriver_screen.dart';

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
        GoRideScreen.id: (context) => GoRideScreen(),
        HistoryScreen.id: (context) => HistoryScreen(),
        WaitingDriverScreen.id: (context) => WaitingDriverScreen(),
      },
    );
  }
}
