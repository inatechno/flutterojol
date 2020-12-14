import 'dart:async';

import 'package:costumerojol/helper/myconstant.dart';
import 'package:costumerojol/model/pin_pill_info.dart';
import 'package:costumerojol/network/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DetailDriverScreen extends StatefulWidget {
  String idDriver;
  DetailDriverScreen({Key key, this.idDriver}) : super(key: key);

  static String id = "detaildriver";
  @override
  _DetailDriverScreenState createState() => _DetailDriverScreenState();
}

class _DetailDriverScreenState extends State<DetailDriverScreen> {
  Timer _timer;
  int _start = 10;
  Network networkOjol = Network();

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location = Location();
    polylinePoints = PolylinePoints();
    location.onLocationChanged.listen((LocationData loc) {
      currentLocation = loc;
      updatePinOnMap();
    });
    setMarkerIcons();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Future<void> updatePinOnMap() async {
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

  void setMarkerIcons() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'images/marker_pin.png')
        .then((onValue) {
      sourceIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'images/marker_destination.png')
        .then((onValue) {
      destinationIcon = onValue;
    });
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 3);
    _timer = Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start > 1) {
                checkDriverLocation();
                print("refresh");
              }
            }));
  }

  void checkDriverLocation() {}
}
