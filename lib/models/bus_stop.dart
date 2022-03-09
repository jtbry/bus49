import 'package:latlong2/latlong.dart';

class BusStop {
  final String id;
  final LatLng pos;
  final String name;

  const BusStop({
    required this.id,
    required this.pos,
    required this.name,
  });
}
