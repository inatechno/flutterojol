import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:myfirstapp_flutter/helper/helper.dart';
import 'package:myfirstapp_flutter/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoRideScreen extends StatefulWidget {
  static String id = "goride";
  @override
  _GoRideScreenState createState() => _GoRideScreenState();
}

class _GoRideScreenState extends State<GoRideScreen> {
// icon marker
  BitmapDescriptor originLocationIcon;
  BitmapDescriptor destinationLocationIcon;
  BitmapDescriptor pinMarkerIcon;
  String googleApiKey = "AIzaSyA961qUUYeU2tnBuk4gS1fpiXVjnCFnbcQ";
  Set<Marker> _markers = Set<Marker>();
  Location location = Location();
  LocationData currentLocation;
  LocationData originLatLng;
  LocationData destinationLatLng;
  double CAMERA_ZOOM = 16;
  double CAMERA_TILT = 80;
  double CAMERA_BEARING = 30;
  Completer<GoogleMapController> _controller = Completer();
  bool isShowPinMarker = false;
  bool isSelectOrigin = false;
  bool isSelectDestination = false;
  bool isReviewRouteBeforeOrder = false;
  bool isReadyToCreateNewOrder = true;
  String originAddress;
  String destinationAddress;

  double distance = 0;
  int cost = 0;
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = Set<Polyline>();
  TextEditingController _catatan = TextEditingController();
  Network networkOjol = Network();

  String iduser, token, device;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInitialLocation();
    setMarkerIcon();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: currentLocation != null
            ? LatLng(currentLocation.latitude, currentLocation.longitude)
            : LatLng(-6.1753924, 106.8249641));

    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  mapType: MapType.normal,
                  markers: _markers,
                  polylines: polylines,
                  tiltGesturesEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    moveToCurrentLocation();
                  },
                  onCameraIdle: () async {
                    print("camera idle");
                    if (isSelectOrigin) {
                      // originAddress = await getCurrentAddress();
                      originLatLng = LocationData.fromMap({
                        "latitude": currentLocation.latitude,
                        "longitude": currentLocation.longitude
                      });
                    }
                    if (isSelectDestination) {
                      // destinationAddress = await getCurrentAddress();
                      destinationLatLng = LocationData.fromMap({
                        "latitude": currentLocation.latitude,
                        "longitude": currentLocation.longitude
                      });
                    }
                  },
                  onCameraMove: (position) {
                    currentLocation = LocationData.fromMap({
                      "latitude": currentLocation.latitude,
                      "longitude": currentLocation.longitude
                    });
                    if (isShowPinMarker) {
                      print("marker drag jalan");
                      var pinPosition = LatLng(
                          position.target.latitude, position.target.longitude);
                      setState(() {
                        _markers.removeWhere(
                            (element) => element.markerId.value == "pinMarker");
                        _markers.add(Marker(
                            markerId: MarkerId("pinMarker"),
                            position: pinPosition,
                            icon: pinMarkerIcon));
                      });
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> setInitialLocation() async {
    currentLocation = await location.getLocation();
    originLatLng = await location.getLocation();
  }

  Future<void> setMarkerIcon() async {
    originLocationIcon =
        await getBitmapDescriptorFromAssetBytes("images/marker_start.png", 100);
    destinationLocationIcon = await getBitmapDescriptorFromAssetBytes(
        "images/marker_destination.png", 100);
    pinMarkerIcon =
        await getBitmapDescriptorFromAssetBytes("images/marker_pin.png", 100);
  }

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    iduser = preferences.getString("iduser");
    token = preferences.getString("token");
    device = await getId();
    print("token" + token + "\n device" + device);
    moveToCurrentLocation();
  }
  //

  Future<void> moveToCurrentLocation({LocationData locationData}) async {
    if (currentLocation == null) currentLocation = await location.getLocation();
    if (locationData == null) locationData = currentLocation;
    CameraPosition position = CameraPosition(
        zoom: CAMERA_ZOOM,
        target: LatLng(locationData.latitude, locationData.longitude));

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
    if (isShowPinMarker) {
      setState(() {
        var pinPosition = LatLng(locationData.latitude, locationData.longitude);
        deleteMarkerByID("pin");
        _markers.add(Marker(
            markerId: MarkerId("pin"),
            position: pinPosition,
            icon: pinMarkerIcon));
      });
    }
  }

  void deleteMarkerByID(String s) {
    _markers.removeWhere((element) => element.markerId.value == s);
  }
}
