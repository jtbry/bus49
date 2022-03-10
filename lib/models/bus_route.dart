import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class BusRoute {
  final String id;
  final String name;
  final Color color;
  final List<Polyline> routeLines;
  bool enabled;

  BusRoute({
    required this.id,
    required this.name,
    required this.color,
    required this.routeLines,
    required this.enabled,
  });
}
