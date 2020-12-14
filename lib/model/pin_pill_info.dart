import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinInformation {
  String pinPath;
  String avatarPath;
  LatLng location;
  String locationName;
  Color labelColor;
  String name;
  String nohp;
  PinInformation(
      {this.pinPath,
      this.avatarPath,
      this.location,
      this.locationName,
      this.labelColor,
      this.name,
      this.nohp});
}
