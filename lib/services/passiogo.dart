import 'dart:convert';

import 'package:bus49/models/bus.dart';
import 'package:bus49/models/bus_route.dart';
import 'package:bus49/models/bus_stop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/map_data.dart';

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
          course: childValue['calculatedCourse'] != null
              ? double.parse(childValue['calculatedCourse'])
              : 0.0,
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
