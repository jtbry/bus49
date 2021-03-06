import 'package:bus49/models/bus.dart';
import 'package:bus49/models/bus_route.dart';
import 'package:bus49/models/bus_stop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapData {
  final LatLng defaultCenter;
  final List<BusRoute> routes;
  final List<BusStop> stops;
  List<Bus> buses;
  LatLng? userLocation;

  MapData({
    required this.defaultCenter,
    required this.routes,
    required this.stops,
    required this.buses,
    this.userLocation,
  });

  List<Marker> generateMarkers(Function(dynamic) triggerMarkerInfo) {
    List<Marker> markers = [];

    Iterable<BusStop> enabledStops =
        stops.where((stop) => stop.routes.any((route) => route.enabled));
    for (BusStop stop in enabledStops) {
      markers.add(Marker(
          point: stop.pos,
          builder: (context) {
            return GestureDetector(
              child: Icon(Icons.circle,
                  size: 16,
                  color:
                      stop.routes.firstWhere((route) => route.enabled).color),
              onTap: () => triggerMarkerInfo(stop),
              behavior: HitTestBehavior.translucent,
            );
          }));
    }

    for (Bus bus in buses) {
      if (bus.route.enabled) {
        markers.add(Marker(
            point: bus.pos,
            builder: (context) {
              return GestureDetector(
                child: Transform.rotate(
                  angle: (bus.course) * 2.0 * pi / 365.0,
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: bus.route.color, width: 3),
                      ),
                      child: Icon(
                        Icons.directions_bus,
                        color: bus.route.color,
                        size: 20,
                      )),
                ),
                onTap: () => triggerMarkerInfo(bus),
                behavior: HitTestBehavior.translucent,
              );
            }));
      }
    }

    if (userLocation != null) {
      markers.add(Marker(
          point: userLocation!,
          builder: (context) =>
              const Icon(Icons.person_pin, color: Colors.green)));
    }

    return markers;
  }

  List<Polyline> generatePolylines() {
    List<Polyline> polylines = [];
    for (BusRoute route in routes) {
      if (route.enabled) {
        for (Polyline line in route.routeLines) {
          polylines.add(line);
        }
      }
    }
    return polylines;
  }
}
