import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class MapData {
  final LatLng center;
  final List<BusRoute> routes;
  List<Bus> buses;

  MapData({
    required this.center,
    required this.routes,
    required this.buses,
  });

  List<Marker> generateMarkers(Function(dynamic) triggerMarkerInfo) {
    List<Marker> markers = [];
    for (BusRoute route in routes) {
      if (route.enabled) {
        for (BusStop stop in route.stops) {
          markers.add(Marker(
              point: stop.pos,
              builder: (context) {
                return GestureDetector(
                  child: Icon(Icons.circle, size: 16, color: route.color),
                  onTap: () {
                    triggerMarkerInfo(stop);
                  },
                  behavior: HitTestBehavior.translucent,
                );
              }));
        }
      }
    }

    for (Bus bus in buses) {
      if (bus.route.enabled) {
        // TODO: better and more visible marker?
        markers.add(Marker(
            point: bus.pos,
            builder: (context) {
              return const Icon(
                Icons.bus_alert,
                color: Colors.red,
                size: 20,
              );
            }));
      }
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

class BusRoute {
  final String id;
  final String name;
  final Color color;
  final List<Polyline> routeLines;
  final List<BusStop> stops;
  bool enabled;

  BusRoute({
    required this.id,
    required this.name,
    required this.color,
    required this.routeLines,
    required this.stops,
    required this.enabled,
  });
}

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

class Bus {
  final int deviceId;
  final int busId;
  final int paxLoad;
  final int paxCap;
  final BusRoute route;
  final LatLng pos;

  const Bus({
    required this.deviceId,
    required this.busId,
    required this.paxLoad,
    required this.paxCap,
    required this.route,
    required this.pos,
  });
}

Future<MapData> fetchMapData() async {
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
  };
  var request = http.Request(
      'POST',
      Uri.parse(
          'https://passio3.com/www/mapGetData.php?getStops=2&wTransloc=1'));
  request.body = '''json=%7B%22s0%22%3A%221053%22%2C%22sA%22%3A1%7D''';
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode != 200) {
    throw Exception('fetchMapData: ${response.reasonPhrase}');
  }

  // Decode json
  var json = jsonDecode(await response.stream.bytesToString());

  // Parse routes
  List<BusRoute> routes = [];
  json['routes'].forEach((key, value) {
    // Parse route polylines
    List<Polyline> lines = [];
    for (dynamic line in json['routePoints'][key]) {
      List<LatLng> points = [];
      for (dynamic point in line) {
        if (point == null) continue;
        points.add(LatLng(
          double.parse(point['lat']),
          double.parse(point['lng']),
        ));
      }
      lines.add(Polyline(
        points: points,
        color: _hexToColor(json['routes'][key][1]),
        strokeWidth: 3,
      ));
    }

    // Parse route stops
    List<BusStop> stops = [];
    for (var i = 2; i < json['routes'][key].length; i++) {
      var id = 'ID${json['routes'][key][i][1]}';
      stops.add(BusStop(
        id: id,
        pos: LatLng(
          json['stops'][id]['latitude'],
          json['stops'][id]['longitude'],
        ),
        name: json['stops'][id]['name'],
      ));
    }

    // Add route to array
    routes.add(BusRoute(
      id: key,
      name: json['routes'][key][0],
      color: _hexToColor(json['routes'][key][1]),
      routeLines: lines,
      stops: stops,
      enabled: false,
    ));
  });

  routes.first.enabled = true;

  // Get bus data
  List<Bus> buses = await fetchBusData(routes);

  return MapData(
    center: LatLng(35.3066662742558, -80.7345842848605),
    routes: routes,
    buses: buses,
  );
}

Future<List<Bus>> fetchBusData(List<BusRoute> routes) async {
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
  };
  var request = http.Request(
      'POST',
      Uri.parse(
          'https://passio3.com/www/mapGetData.php?getBuses=1&wTransloc=1'));
  request.body = '''json=%7B%22s0%22%3A%221053%22%2C%22sA%22%3A1%7D''';
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  if (response.statusCode != 200) {
    throw Exception('fetchMapData: ${response.reasonPhrase}');
  }

  // Decode json
  var json = jsonDecode(await response.stream.bytesToString());
  List<Bus> buses = [];
  json['buses'].forEach((key, value) {
    value.forEach((childValue) {
      buses.add(
        Bus(
          deviceId: childValue['deviceId'],
          busId: childValue['busId'],
          paxLoad: childValue['paxLoad'],
          paxCap: childValue['totalCap'],
          route: routes
              .firstWhere((element) => element.id == childValue['routeId']),
          pos: LatLng(double.parse(childValue['latitude']),
              double.parse(childValue['longitude'])),
        ),
      );
    });
  });
  return buses;
}

Color _hexToColor(String hex) {
  hex = hex.toUpperCase().replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF" + hex;
  }
  return Color(int.parse(hex, radix: 16));
}
