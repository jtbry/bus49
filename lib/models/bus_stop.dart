import 'package:latlong2/latlong.dart';

import 'bus_route.dart';

class BusStop {
  final String id;
  final LatLng pos;
  final String name;
  final String pureId;
  List<BusRoute> routes;

  BusStop({
    required this.id,
    required this.pos,
    required this.name,
    required this.pureId,
    required this.routes,
  });
}
