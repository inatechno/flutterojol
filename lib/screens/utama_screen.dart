import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import '../helper/helper.dart';
import '../model/pin_pill_info.dart';
import '../network/network.dart';
import '../model/model_history.dart';
import 'package:driverojol/widgets/map_pin_pill.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'history_screen.dart';
import 'login_screen.dart';

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  var datax = data['datax'];
  // var datax = dataxx['datax'];
  //  var click_action = data['click_action'];
  var dataxItem = jsonDecode(datax)['datax']['data'];
  DataHistory dataBooking = DataHistory.fromJson(dataxItem);
  String idBooking = dataBooking.idBooking;
  print("idbooking:" + idBooking);
  // final String itemId = data['id'];
  final Item item = _items.putIfAbsent(
      idBooking,
      () => Item(
          itemId: idBooking,
          origin: dataBooking.bookingFrom,
          destination: dataBooking.bookingTujuan,
          harga: dataBooking.bookingBiayaDriver,
          jarak: dataBooking.bookingJarak,
          latcostumer: dataBooking.bookingFromLat,
          lngcostumer: dataBooking.bookingFromLng))
    ..status = jsonDecode(datax)['datax']['result'];
  return item;
}

class Item {
  Item(
      {this.itemId,
      this.origin,
      this.destination,
      this.harga,
      this.jarak,
      this.latcostumer,
      this.lngcostumer});
  final String itemId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;
  String origin, destination, harga, jarak, latcostumer, lngcostumer;
  String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailDriverScreen(itemId),
      ),
    );
  }
}

class UtamaScreen extends StatefulWidget {
  static String id = "utama";
  @override
  _UtamaScreenState createState() => _UtamaScreenState();
}

class _UtamaScreenState extends State<UtamaScreen> {
  int number = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _homeScreenText = "Waiting for token...";
  String fcm;
  bool isSwitched = true;

  static final List<String> imgSlider = [
    'images/ojek7.jpg',
    'images/ojek8.jpg',
    'images/ojek9.jpg',
    'images/ojek10.jpg',
    'images/ojek11.jpg',
    'images/ojek12.jpg',
    'images/ojek13.png',
    // 'images/ojek6.jpg',
  ];

  static final List<Widget> imageSliders = imgSlider.map((item) {
    var index = imgSlider.indexOf(item);
    return Container(
        child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: Stack(
        children: [
          // index == 0
          //     ?
          Image.asset(
            item,
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),

          Positioned(
              bottom: 10,
              child: Container(
                  // child: Text(
                  //   "no ${imgSlider.indexOf(item)} image",
                  //   style: TextStyle(fontSize: 25, color: Colors.white),
                  // ),
                  ))
        ],
      ),
    ));
  }).toList();

  String tokenUpdate;
  Network network = Network();
  String iduser;
  String token;
  String device;

  String todayEarning;

  String todayRating;

  String todayTrip;
  // bool click;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _navigateToItemDetail(message);
        _showItemDialog(message);

        // if (click == true) {
        //   _showItemDialog(message);
        // }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _navigateToItemDetail(message);
        // _showItemDialog(message);
        _showItemDialog(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        tokenUpdate = token;
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);

      if (fcm == '') {
        setTokenToPref(tokenUpdate);
        insertTokenToDb();
      }
    });
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text(
        "Item ${item.itemId} has been updated :",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, bottom: 10, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.person_pin_circle),
                    Text("Origin : " + item.origin)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.person_pin_circle),
                    Text("Destination : " + item.destination)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Jarak : " + item.jarak),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Harga : " + item.harga,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  FlatButton(
                    child: const Text('Tolak'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  FlatButton(
                    child: const Text('Terima'),
                    onPressed: () {
                      setState(() {
                        // click = false;
                      });
                      takeBooking(item.itemId);
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  //navigasi ke halaman detail ketika tombol (ex:show) ditekan
  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    //carousel slider indicator

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/inatech5.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OFFLINE",
                style: TextStyle(
                    color: isSwitched == false ? Colors.white : Colors.black38),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                    if (isSwitched == true) {
                      print("true ya gaes");
                      statusOn();
                    } else {
                      print("faalse ya gaes");
                      statusOff();
                    }
                    print(isSwitched);
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
              Text("ONLINE",
                  style: TextStyle(
                      color:
                          isSwitched == true ? Colors.white : Colors.black38)),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.clear();
                  statusOn();
                  Navigator.popAndPushNamed(context, LoginScreen.id);
                })
          ],
        ),
        body: Column(
          children: [
            user(),
            menu(),
            slider(),
          ],
        ),
      ),
    );
  }

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    fcm = preferences.getString('fcm') ?? '';
    iduser = preferences.getString("iduser");
    token = preferences.getString("token");
    var status = preferences.getBool("status");
    print("statusku" + status.toString());
    device = await getId();
    getData();
    if (status == true) {
      setState(() {
        isSwitched = true;
      });
    } else if (status == false) {
      setState(() {
        isSwitched = false;
      });
    }

    // print("token" + token + "\n device" + device);
  }

  menu() {
    return Flexible(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Flexible(
                  flex: 5,
                  child: Row(
                    children: [
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // tampilanMenu("Live Location", "images/driver.png",
                      //     Colors.blue, GoRideScreen.id),
                      // SizedBox(
                      //   width: 10,
                      // ),
                      tampilanMenu("History", "images/trip.png",
                          Colors.blue[200], HistoryScreen.id),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )),
              Flexible(
                child: SizedBox(
                  height: 10,
                ),
              ),
              Flexible(
                  flex: 5,
                  child: Row(
                    children: [
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // tampilanMenu("pesan ojek", "images/ojek.png",
                      //     Colors.blue[200], GoRideScreen.id),

                      SizedBox(
                        width: 10,
                      ),
                      tampilanMenu("My Profile", "images/myprofile.png",
                          Colors.blue[200], HistoryScreen.id),
                      SizedBox(
                        width: 10,
                      ),
                      tampilanMenu("My Rating", "images/menu2.png",
                          Colors.blue[200], HistoryScreen.id),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }

  Widget tampilanMenu(String title, String images, Color warna, String tujuan) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, tujuan);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // color: warna,
          decoration: BoxDecoration(
              color: Colors.white,
              // border: Border.all(
              //     // color: Colors.blue[500],
              //     ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                images != null
                    ? Flexible(
                        flex: 2,
                        child: Image.asset(
                          images,
                          color: Colors.blue,
                        ),
                      )
                    : Image.network(""),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  slider() {
    return Flexible(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              // carousel slider
              Flexible(
                flex: 8,
                child: mySlider(),
              ),
              SizedBox(
                height: 5,
              )
              // point slider
              // Flexible(child: widgetPoint())
            ],
          ),
        ));
  }

  Widget mySlider() {
    final CarouselSlider autoPlayImage = CarouselSlider(
      options: CarouselOptions(
        height: 600,
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
              color: number == index ? Colors.black : Colors.blue),
        );
      }).toList(),
    );
  }

  setTokenToPref(String tokenUpdate) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('fcm', tokenUpdate);
    print("token_anda:" + tokenUpdate);
  }

  insertTokenToDb() {
    network.registerFcm(iduser, tokenUpdate).then((response) {
      if (response.result == "true") {
        print("berhasil: insert fcm" + tokenUpdate);
        Toast.show(response.msg, context);
      } else {
        print("gagal: insert fcm");
        Toast.show(response.msg, context);
      }
    });
  }

  takeBooking(String itemId) {
    // network.takeBooking(iduser, itemId, device, token).then((response) {
    //   if (response.result == "true") {
    //     Toast.show(response.msg, context);
    //   } else {
    //     Toast.show(response.msg, context);
    //   }
    // });
  }

  void statusOff() {
    // network.statusOff(iduser, token, device).then((response) async {
    //   if (response.result == "true") {
    //     Toast.show(response.msg, context);
    //     SharedPreferences sharedPreferences =
    //         await SharedPreferences.getInstance();
    //     sharedPreferences.setBool("status", false);
    //   } else {
    //     Toast.show(response.msg, context);
    //   }
    // });
  }

  void statusOn() {
    // network.statusOn(iduser, token, device).then((response) async {
    //   if (response.result == "true") {
    //     Toast.show(response.msg, context);
    //     SharedPreferences sharedPreferences =
    //         await SharedPreferences.getInstance();
    //     sharedPreferences.setBool("status", true);
    //   } else {
    //     Toast.show(response.msg, context);
    //   }
    // });
  }

  user() {
    return Flexible(
        flex: 3,
        child: Container(
          // color: Colors.blue,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage("images/menu4.png"),
                  radius: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Iswandi Saputra",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        // border: Border.all(
                        //     // color: Colors.blue[500],
                        //     ),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "IDR",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "450.000",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                            radius: (30),
                            backgroundColor: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                  // borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                "images/menu5.png",
                                color: Colors.white,
                              )),
                            )),
                        Text(
                            todayEarning != null
                                ? "💰${todayEarning}"
                                : "belum ada",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Image.asset(
                            "images/menu2.png",
                            color: Colors.white,
                          ),
                          // backgroundImage: AssetImage("images/menu2.png"),
                          radius: 30,
                        ),
                        Text(
                            todayRating != null
                                ? "⭐️${todayRating}"
                                : "belum ada",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Image.asset(
                            "images/menu3.png",
                            color: Colors.white,
                          ),
                          // backgroundImage: AssetImage("images/menu3.png"),
                          radius: 30,
                        ),
                        Text(todayTrip != null ? "🗾${todayTrip}" : "belum ada",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  getData() {
    print("iduser" + iduser + token + device);
    // network.getTodayEarning(iduser, token, device).then((response) {
    //   if (response.result == "true") {
    //     setState(() {
    //       todayEarning = response.data[0].total;
    //     });
    //     print("berhasil get data today earning");
    //   } else {
    //     print("gagal get data today earning");
    //   }
    // });

    // network.getTodayRating(iduser, token, device).then((response) {
    //   if (response.result == "true") {
    //     setState(() {
    //       double a = double.parse(response.data[0].total);
    //       // RegExp regex = RegExp(r"([.]*0)(?!.*\d)");

    //       todayRating = a.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    //       // todayRating = response.data[0].total;
    //     });
    //     print("berhasil get data today rating");
    //   } else {
    //     print("gagal get data today rating");
    //   }
    // });
    // network.getTodayTrip(iduser, token, device).then((response) {
    //   if (response.result == "true") {
    //     setState(() {
    //       todayTrip = response.data.length.toString();
    //       // todayRating = response.data[0].total;
    //     });
    //     print("berhasil get data today rating");
    //   } else {
    //     print("gagal get data today rating");
    //   }
    // });
  }
}

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(-6.2969516, 106.6962871);

class DetailDriverScreen extends StatefulWidget {
  static String id = "detailsc";
  final String itemId;
  DetailDriverScreen(this.itemId);

  @override
  _DetailDriverScreenState createState() => _DetailDriverScreenState();
}

class _DetailDriverScreenState extends State<DetailDriverScreen>
    with AutomaticKeepAliveClientMixin {
  Item _item;
  StreamSubscription<Item> _subscription;
  Map<String, Item> itemsbaru = <String, Item>{};
  Timer _timer;
  int _start = 10;
  Network network = Network();

  String latDriver;
  String longDriver;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleAPIKey = 'AIzaSyA961qUUYeU2tnBuk4gS1fpiXVjnCFnbcQ';
// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
    pinPath: '',
    avatarPath: '',
    location: LatLng(0, 0),
    locationName: '',
    labelColor: Colors.grey,
  );
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;

  String originAdress;
  String iduser, token, device;
  String idbooking, latcos, lngcos;
  @override
  void initState() {
    super.initState();
    getDataPref();
    // create an instance of Location
    location = new Location();
    polylinePoints = PolylinePoints();

    if (_items[widget.itemId] != null) {
      _item = _items[widget.itemId];
      _subscription = _item.onChanged.listen((Item item) {
        if (!mounted) {
          _subscription.cancel();
        } else {
          setState(() {
            _item = item;
          });
        }
      });
    }

    // Toast.show(_item.itemId, context);
    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
      updatePinOnMap();
    });
    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location

    startTimer();
    getPref();
  }

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idbooking = preferences.getString("idbooking") ?? '';
    iduser = preferences.getString("iduser");
    token = preferences.getString("token");
    device = await getId();

    if (idbooking == '') {
      preferences.setString("idbooking", _item.itemId);
      preferences.setString("lat", _item.latcostumer);
      preferences.setString("lng", _item.lngcostumer);
      print("berhasil:simpan");
    } else {
      print("berhasil:gagal");
    }
  }

  checkLokasiDriver() {
    setState(() {
      latDriver = _item?.latcostumer ?? latcos;
      longDriver = _item?.lngcostumer ?? lngcos;
    });
    print("lat: $latDriver \n lng: $longDriver");
    showPinsOnMap();
    print("idbooking: blum bisa ");
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 3);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start > 1) {
            checkLokasiDriver();
            print("refresh y");
            setInitialLocation();
            insertLokasi();
          }
        },
      ),
    );
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'images/marker_motor.png')
        .then((onValue) {
      sourceIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'images/marker_costumer.png')
        .then((onValue) {
      destinationIcon = onValue;
    });
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({
      "latitude": double.parse(latDriver),
      "longitude": double.parse(longDriver),
    });
    print("init masuk" +
        LatLng(double.parse(latDriver), double.parse(longDriver)).toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_item?.itemId ?? idbooking),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onTap: (LatLng loc) {
                pinPillPosition = -100;
              },
              onMapCreated: (GoogleMapController controller) {
                // controller.setMapStyle(Utils.mapStyles);
                _controller.complete(controller);
                // my map has completed being created;
                // i'm ready to show the pins on the map
                showPinsOnMap();
              }),
          Positioned(
              top: 8,
              left: 60,
              right: 60,
              child: RaisedButton(
                onPressed: () {
                  completeBooking();
                },
                color: Colors.blue[400],
                child: Text(
                  "complete booking",
                  style: TextStyle(color: Colors.white),
                ),
              )),
          sourcePinInfo == null
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), Text("sabar ya...")],
                ))
              : Container(),
          MapPinPillComponent(
              pinPillPosition: pinPillPosition,
              currentlySelectedPin: currentlySelectedPin)
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> showPinsOnMap() async {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
        LatLng(destinationLocation.latitude, destinationLocation.longitude);
    print("masuk");
    originAdress = await getCurrentAddress();
    sourcePinInfo = PinInformation(
        locationName: originAdress,
        location: SOURCE_LOCATION,
        pinPath: "images/marker_start.png",
        avatarPath: "images/friend1.jpg",
        labelColor: Colors.blueAccent);

    destinationPinInfo = PinInformation(
        locationName: "End Location",
        location: LatLng(double.parse(latDriver), double.parse(longDriver)),
        pinPath: "images/marker_costumer.png",
        avatarPath: "images/friend2.jpg",
        labelColor: Colors.purple);
    print("laat:" + latDriver + "\nlong:" + longDriver);
    print(LatLng(double.parse(latDriver), double.parse(longDriver)).toString());

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        icon: destinationIcon));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial

    setPolylines();
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(currentLocation.latitude, currentLocation.longitude),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
    );
    polylineCoordinates.clear();
    if (result != null) {
      print("Results not null");
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        setState(() {
          if (result != null) {
            print("Results not null");
            if (result.points.isNotEmpty) {
              _polylines.add(Polyline(
                  width: 2, // set the width of the polylines
                  polylineId: PolylineId("poly"),
                  color: Color.fromARGB(255, 40, 122, 198),
                  points: polylineCoordinates));
            }
          }
        });
      }
    }
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      sourcePinInfo.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }

  Future<String> getCurrentAddress() async {
    final coordinates =
        Coordinates(currentLocation.latitude, currentLocation.longitude);
    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var firstLocation = address.first;
    return firstLocation.addressLine;
  }

  Future<void> getDataPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var dataitems = preferences.getString("items");

    setState(() {
      idbooking = preferences.getString("idbooking");
      latcos = preferences.getString("lat");
      lngcos = preferences.getString("lng");
    });
  }

  void completeBooking() {
    // network
    //     .completeBooking(iduser, _item?.itemId ?? idbooking, token, device)
    //     .then((response) async {
    //   SharedPreferences preferences = await SharedPreferences.getInstance();
    //   preferences.remove("idbooking");
    //   if (response.result == "true") {
    //     Toast.show(response.msg, context);

    //     preferences.remove("idbooking");
    //     Navigator.pop(context);
    //   } else {
    //     Toast.show(response.msg, context);
    //   }
    // });
  }

  insertLokasi() {
    // network
    //     .insertLokasi(iduser, currentLocation.latitude.toString(), token,
    //         device, currentLocation.longitude.toString())
    //     .then((response) {
    //   if (response.result == "true") {
    //     print("berhasil update lokasi");
    //   } else {
    //     print("gagal update lokasi");
    //   }
    // });
  }
}
