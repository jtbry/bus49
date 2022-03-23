import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng> getUserLocation() async {
  // TODO: fix asking for user location twice
  // TODO: fix user location not working firefox iOS
  // TODO: fix load time while waiting for user location
  // TODO: fix android emulator needing google play services?
  Location location = Location();
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      throw Exception("Service Not Enabled");
    }
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied &&
      permissionGranted != PermissionStatus.deniedForever) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      throw Exception("Missing Location Permissions");
    }
  }

  LocationData data = await location.getLocation();
  return LatLng(data.latitude!, data.longitude!);
}
