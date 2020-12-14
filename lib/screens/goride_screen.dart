import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indonesia/indonesia.dart';
import 'package:location/location.dart';
import 'package:costumerojol/helper/helper.dart';
import 'package:costumerojol/network/network.dart';
import 'package:costumerojol/screens/waitingdriver_screen.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

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
  Network network = Network();

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
                      originAddress = await getCurrentAddress();
                      originLatLng = LocationData.fromMap({
                        "latitude": currentLocation.latitude,
                        "longitude": currentLocation.longitude
                      });
                    }
                    if (isSelectDestination) {
                      destinationAddress = await getCurrentAddress();
                      destinationLatLng = LocationData.fromMap({
                        "latitude": currentLocation.latitude,
                        "longitude": currentLocation.longitude
                      });
                    }
                  },
                  onCameraMove: (position) {
                    currentLocation = LocationData.fromMap({
                      "latitude": position.target.latitude,
                      "longitude": position.target.longitude
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
                ),
                (isSelectOrigin || isSelectDestination)
                    ? Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        child: SearchMapPlaceWidget(
                          apiKey: googleApiKey,
                          onSelected: (place) async {
                            final geolocation = await place.geolocation;
                            currentLocation = LocationData.fromMap({
                              "latitude": geolocation.coordinates.latitude,
                              "longitude": geolocation.coordinates.longitude
                            });
                          },
                        ),
                      )
                    : Container(),
                (isSelectOrigin || isSelectDestination)
                    ? Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          padding: EdgeInsets.all(8),
                          child: RaisedButton(
                            onPressed: () async {
                              if (isSelectOrigin) {
                                setState(() {
                                  isSelectOrigin = false;
                                  isSelectDestination = true;
                                  setOriginMarker();
                                });
                              } else {
                                distance = await countDistance();
                                cost = await countCost();
                                setState(() {
                                  isSelectDestination = false;
                                  isShowPinMarker = false;
                                  isReviewRouteBeforeOrder = true;
                                  deleteMarkerByID("pinMarker");
                                  setDestinationMarker();
                                  setPolylineOrder();
                                });
                              }
                            },
                            color: Colors.orange,
                            textColor: Colors.white,
                            child: Text(isSelectOrigin
                                ? " SET LOKASI JEMPUT "
                                : " SET LOKASI ANTAR "),
                          ),
                        ),
                      )
                    : Container(),
                isReadyToCreateNewOrder
                    ? Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          padding: EdgeInsets.all(8),
                          child: RaisedButton(
                            onPressed: () => createNewOrder(),
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text("BUAT ORDER BARU"),
                          ),
                        ))
                    : Container(),
                isReviewRouteBeforeOrder
                    ? Positioned(
                        bottom: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: FloatingActionButton(
                                onPressed: () => cancelOrder(),
                                child: Icon(Icons.close,
                                    color: Colors.orange[900]),
                                backgroundColor: Colors.white,
                                mini: true,
                                elevation: 2,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(15),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      originAddress ?? "tidak ditemukan",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            //garis pembatas
                            Divider(
                              height: 2,
                              color: Colors.orange[900],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(15),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    size: 16,
                                    color: Colors.orange[900],
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      destinationAddress ?? "tidak ditemukan",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(15),
                                color: Colors.white,
                                child: TextField(
                                  controller: _catatan,
                                  decoration: InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.orange[900])),
                                      hintText: "Inputkan Catatan"),
                                )),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(15),
                                color: Colors.white,
                                child: RaisedButton(
                                  onPressed: () => insertBooking(),
                                  color: Colors.orange[900],
                                  textColor: Colors.white,
                                  elevation: 5,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Order (${distance.toStringAsFixed(1)} Km"),
                                      Text(rupiah(cost))
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      )
                    : Container()
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
        // _markers.add(Marker(
        //     markerId: MarkerId("pin"),
        //     position: pinPosition,
        //     icon: pinMarkerIcon));
      });
    }
  }

  void deleteMarkerByID(String s) {
    _markers.removeWhere((element) => element.markerId.value == s);
  }

  void setOriginMarker() {
    _markers.add(Marker(
        markerId: MarkerId("originMarker"),
        position: LatLng(originLatLng.latitude, originLatLng.longitude),
        icon: originLocationIcon));
  }

  //menghitung jarak
  countDistance() async {
    double distance = await Geolocator.distanceBetween(
        originLatLng.latitude,
        originLatLng.longitude,
        destinationLatLng.latitude,
        destinationLatLng.longitude);
    return distance / 1000;
  }

  countCost() async {
    int cost = 9000;
    double distance = await countDistance();
    if (distance > 5) {
      int additinalCost = (distance.round() - 5) * 3000;
      cost += additinalCost;
    }
    return cost;
  }

  void setDestinationMarker() {
    _markers.add(Marker(
        markerId: MarkerId("destinationMarker"),
        position:
            LatLng(destinationLatLng.latitude, destinationLatLng.longitude),
        icon: destinationLocationIcon));
  }

  Future<void> setPolylineOrder() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(originLatLng.latitude, originLatLng.longitude),
        PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude));
    polylineCoordinates.clear();
    polylines
        .removeWhere((element) => element.polylineId.value == "orderRoute");
    if (result.points.isNotEmpty) {
      result.points.forEach((point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        polylines.add(Polyline(
            polylineId: PolylineId("orderRoute"),
            width: 5,
            points: polylineCoordinates,
            color: Colors.orange[900]));
      });
    }
  }

  createNewOrder() async {
    originAddress = await getCurrentAddress();
    originLatLng = LocationData.fromMap({
      "latitude": currentLocation.latitude,
      "longitude": currentLocation.longitude
    });
    destinationLatLng = null;
    destinationAddress = null;
    isReadyToCreateNewOrder = false;
    polylines.clear();
    _markers.removeWhere((m) => m.markerId.value == "originMarker");
    _markers.removeWhere((m) => m.markerId.value == "destinationMarker");
    isSelectOrigin = true;
    isShowPinMarker = true;
    moveToCurrentLocation();
  }

  getCurrentAddress() async {
    final coordinates =
        Coordinates(currentLocation.latitude, currentLocation.longitude);
    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var firstLocation = address.first;
    return firstLocation.addressLine;
  }

  insertBooking() {
    network
        .insertBooking(
            iduser,
            originLatLng.latitude.toString(),
            originLatLng.longitude.toString(),
            originAddress,
            destinationLatLng.latitude.toString(),
            destinationLatLng.longitude.toString(),
            destinationAddress,
            _catatan.text,
            distance.round().toString(),
            token,
            device)
        .then((response) {
      if (response.result == "true") {
        Toast.show(response.msg, context);
        Navigator.pushNamed(context, WaitingDriverScreen.id,
        arguments: response.idBooking.toString());  
      } else {
        Toast.show(response.msg, context);
      }
    });
  }

  cancelOrder() {
    setState(() {
      originAddress = null;
      originLatLng = null;
      destinationAddress = null;
      destinationLatLng = null;
      isReviewRouteBeforeOrder = false;
      isReadyToCreateNewOrder = true;
      polylines.clear();
      _markers
          .removeWhere((element) => element.markerId.value == "originMarker");
      _markers.removeWhere(
          (element) => element.markerId.value == "destinationMarker");
      isSelectOrigin = false;
      isSelectDestination = false;
    });
  }
}
