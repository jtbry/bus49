import 'dart:convert';

import 'package:bus49/models/bus.dart';
import 'package:bus49/models/bus_route.dart';
import 'package:bus49/models/bus_stop.dart';
import 'package:bus49/models/stop_eta.dart';
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
  for (var key in json['routes'].keys) {
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

    // Add route to array
    BusRoute route = BusRoute(
      id: key,
      name: json['routes'][key][0],
      color: _hexToColor(json['routes'][key][1]),
      routeLines: lines,
      enabled: false,
    );
    routes.add(route);
  }
  routes.first.enabled = true;

  // Parse stops and etas
  List<BusStop> stops = [];
  List<StopEta> etas = [];
  for (BusRoute route in routes) {
    for (var i = 2; i < json['routes'][route.id].length; i++) {
      var pureId = json['routes'][route.id][i][1];
      var stopId = 'ID$pureId';
      try {
        stops.firstWhere((element) => element.id == pureId).routes.add(route);
      } catch (e) {
        stops.add(BusStop(
          id: pureId,
          pureId: pureId,
          pos: LatLng(
            json['stops'][stopId]['latitude'],
            json['stops'][stopId]['longitude'],
          ),
          name: json['stops'][stopId]['name'],
          routes: [route],
        ));
        // TODO: find way to lazy load etas they take too long to load at once
        // etas.addAll(await fetchStopEtas(pureId));
      }
    }
  }

  // Get bus data
  List<Bus> buses = await fetchBusData(routes);

  return MapData(
    center: LatLng(35.3066662742558, -80.7345842848605),
    routes: routes,
    stops: stops,
    buses: buses,
    etas: etas,
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
  for (var value in json['buses'].values) {
    for (var childValue in value) {
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
    }
  }
  return buses;
}

Future<List<StopEta>> fetchStopEtas(
    String stopId, Iterable<BusRoute> routes) async {
  List<StopEta> etas = [];
  for (BusRoute route in routes) {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://passio3.com/www/mapGetData.php?eta=3&wTransloc=1&stopIds=$stopId&routeId=${route.id}'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('fetchStopEta: ${response.reasonPhrase}');
    }

    var json = jsonDecode(await response.stream.bytesToString());
    if (json['ETAs'][stopId] == null) {
      if (json['ETAs']['0000'] != null) {
        stopId = '0000';
      }
      return etas;
    }
    for (var etaJson in json['ETAs'][stopId]) {
      // Don't allow duplicates
      if (!etas.any((element) => element.busName == etaJson['busName'])) {
        etas.add(StopEta.fromJson(etaJson));
      }
    }
  }
  etas.sort((a, b) => a.secondsSpent.compareTo(b.secondsSpent));
  return etas;
}

Color _hexToColor(String hex) {
  hex = hex.toUpperCase().replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF" + hex;
  }
  return Color(int.parse(hex, radix: 16));
}
