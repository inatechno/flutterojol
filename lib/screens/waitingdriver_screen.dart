import 'dart:async';

import 'package:costumerojol/network/network.dart';
import 'package:costumerojol/screens/detaildriver_screen.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class WaitingDriverScreen extends StatefulWidget {
  static String id = "waiting";
  String idBooking;
  WaitingDriverScreen({Key key, this.idBooking}) : super(key: key);
  @override
  _WaitingDriverScreenState createState() => _WaitingDriverScreenState();
}

class _WaitingDriverScreenState extends State<WaitingDriverScreen> {
  Timer _timer;
  int _start = 10;
  Network network = Network();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                    "https://cdn.dribbble.com/users/3374930/screenshots/10843239/media/bfaf4cb31f727902d574301e8715fe75.gif")
              ],
            ),
          ),
        ));
  }

  Future<bool> _willPopCallback() {
    tampilPilihan();
    return Future.value(true);
  }

  void tampilPilihan() {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Batal Order"),
      onPressed: () async {
        Navigator.pop(context);
        // Navigator.pushReplacementNamed(context, LoginScreen.id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Information"),
      content: Text("apakah anda yakin Batal Order?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 3);
    _timer = Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start > 1) {
                checkStatusBooking();
                print("refresh");
              }
            }));
  }

  void checkStatusBooking() {
    network.checkBooking(widget.idBooking).then((response) {
      if (response.result == "true") {
        Toast.show("orderan diterima", context);
        Navigator.popAndPushNamed(context, DetailDriverScreen.id,
            arguments: response.driver);
        _timer.cancel();
      } else {
        Toast.show("sabar ya,, masih mencari driver!", context);
      }
    });
  }
}
