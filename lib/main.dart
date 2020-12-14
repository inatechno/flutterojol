import 'package:costumerojol/screens/detaildriver_screen.dart';
import 'package:flutter/material.dart';
import 'package:costumerojol/screens/goride_screen.dart';
import 'package:costumerojol/screens/history_screen.dart';
import 'package:costumerojol/screens/loadingsplash_screen.dart';
import 'package:costumerojol/screens/login_screen.dart';
import 'package:costumerojol/screens/register_screen.dart';
import 'package:costumerojol/screens/utama_screen.dart';
import 'package:costumerojol/screens/waitingdriver_screen.dart';

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
      onGenerateRoute: (settings) {
        if (settings.name == WaitingDriverScreen.id) {
          return MaterialPageRoute(
            builder: (context) {
              return WaitingDriverScreen(
                idBooking: settings.arguments,
              );
            },
          );
        } else if (settings.name == DetailDriverScreen.id) {
          return MaterialPageRoute(
            builder: (context) {
              return DetailDriverScreen(
                idDriver: settings.arguments,
              );
            },
          );
        }
      },
      initialRoute: LoadingSplashScreen.id,
      routes: {
        LoadingSplashScreen.id: (context) => LoadingSplashScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        UtamaScreen.id: (context) => UtamaScreen(),
        GoRideScreen.id: (context) => GoRideScreen(),
        HistoryScreen.id: (context) => HistoryScreen(),
      },
    );
  }
}
