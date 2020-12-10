import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:myfirstapp_flutter/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'goride_screen.dart';
import 'history_screen.dart';

class UtamaScreen extends StatefulWidget {
  static String id = "utama";
  @override
  _UtamaScreenState createState() => _UtamaScreenState();
}

class _UtamaScreenState extends State<UtamaScreen> {
  int number = 0;
  static final List<String> imgSlider = [
    'images/ojek1.jpg',
    'images/ojek2.png',
    'images/ojek3.jpg',
    'images/ojek4.png',
    'images/ojek5.jpg',
    'images/ojek6.jpg',
  ];

  static final List<Widget> imageSliders = imgSlider
      .map((item) => Container(
              child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Stack(
              children: [
                Image.asset(
                  item,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                    bottom: 10,
                    child: Container(
                      child: Text(
                        "no ${imgSlider.indexOf(item)} image",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ))
              ],
            ),
          )))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showAlertDialog(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          carouselSlider(),
          menu()
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Logout"),
      onPressed: () async {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.clear();
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Information"),
      content: Text("apakah anda yakin untuk LogOut?"),
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

  carouselSlider() {
    return Flexible(
        child: Column(
      children: [
        // carousel slider
        Flexible(
          flex: 8,
          child: mySlider(),
        ),
        // point slider
        Flexible(child: widgetPoint())
      ],
    ));
  }

  Widget mySlider() {
    final CarouselSlider autoPlayImage = CarouselSlider(
      options: CarouselOptions(
        height: 580,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        initialPage: 0,
        onPageChanged: (index, _) {
          setState(() {
            number = index;
          });
        },
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
      items: imageSliders,
    );
    return autoPlayImage;
  }

  widgetPoint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: imgSlider.map((item) {
        int index = imgSlider.indexOf(item);
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: number == index ? Colors.black : Colors.orange),
        );
      }).toList(),
    );
  }

  menu() {
    return Flexible(
        child: Column(
      children: [
        Flexible(
            child: Row(
          children: [
            tampilanMenu("pesan ojek", "images/ojek.png", Colors.orange,
                GoRideScreen.id),
            SizedBox(
              width: 10,
            ),
            tampilanMenu("history", "images/diet.png", Colors.orange[900],
                HistoryScreen.id),
          ],
        )),
        SizedBox(
          height: 10,
        ),
        Flexible(
            child: Row(
          children: [
            tampilanMenu("pesan ojek", "images/ojek.png", Colors.orange[900],
                GoRideScreen.id),
            SizedBox(
              width: 10,
            ),
            tampilanMenu(
                "history", "images/diet.png", Colors.orange, HistoryScreen.id),
          ],
        )),
      ],
    ));
  }

  tampilanMenu(String title, String gambar, Color warna, String id) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, id);
        },
        child: Card(
          elevation: 8,
          color: warna,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
            // color: warna,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                gambar != null
                    ? Image.asset(
                        gambar,
                        width: 80,
                      )
                    : Image.network(""),
                Text(
                  title,
                  style: TextStyle(fontSize: 25, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
