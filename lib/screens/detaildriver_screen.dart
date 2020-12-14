import 'dart:async';

import 'package:costumerojol/helper/myconstant.dart';
import 'package:costumerojol/model/pin_pill_info.dart';
import 'package:costumerojol/network/network.dart';
import 'package:costumerojol/widgets/map_pin_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';

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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            myLocationEnabled: true,
            compassEnabled: true,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            onTap: (loc) {
              pinPillPosition = -100;
            },
            onMapCreated: (controller) {
              _controller.complete(controller);
              showPinsOnMap();
            },
          ),
          sourcePinInfo == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text("Sabar ya,lagi load data driver...")
                    ],
                  ),
                )
              : Container(),
          MapPinPillComponent(
            pinPillPosition: pinPillPosition,
            currentlySelectedPin: currentlySelectedPin,
          )
        ],
      ),
    );
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
                setInitialLocation();
              }
            }));
  }

  void checkDriverLocation() {
    networkOjol.getDetailDriver(widget.idDriver).then((response) {
      if (response.result == "true") {
        setState(() {
          latDriver = response.data[0].trackingLat.toString();
          longDriver = response.data[0].trackingLng.toString();
        });
        print("update location driver");
        showPinsOnMap();
      } else {
        Toast.show(response.msg, context);
      }
    });
  }

  Future<void> showPinsOnMap() async {
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
        pinPath: "images/marker_destination.png",
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

  getCurrentAddress() async {
    final coordinates =
        Coordinates(currentLocation.latitude, currentLocation.longitude);
    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var firstLocation = address.first;
    return firstLocation.addressLine;
  }

  Future<void> setPolylines() async {
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
                  color: Colors.orange[900],
                  points: polylineCoordinates));
            }
          }
        });
      }
    }
  }

  Future<void> setInitialLocation() async {
    currentLocation = await location.getLocation();
    destinationLocation = LocationData.fromMap({
      "latitude": double.parse(latDriver),
      "longitude": double.parse(longDriver),
    });
  }
}
