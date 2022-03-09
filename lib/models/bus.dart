import 'package:bus49/models/bus_route.dart';
import 'package:latlong2/latlong.dart';

class Bus {
  final int deviceId;
  final int busId;
  final int paxLoad;
  final int paxCap;
  final BusRoute route;
  final LatLng pos;
  final double course;

  const Bus({
    required this.deviceId,
    required this.busId,
    required this.paxLoad,
    required this.paxCap,
    required this.route,
    required this.pos,
    required this.course,
  });
}
