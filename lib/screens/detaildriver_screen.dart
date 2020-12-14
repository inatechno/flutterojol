import 'package:flutter/material.dart';

class DetailDriverScreen extends StatefulWidget {
  String idDriver;
  DetailDriverScreen({Key key, this.idDriver}) : super(key: key);

  static String id = "detaildriver";
  @override
  _DetailDriverScreenState createState() => _DetailDriverScreenState();
}

class _DetailDriverScreenState extends State<DetailDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
