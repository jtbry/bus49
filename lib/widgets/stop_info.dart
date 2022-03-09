import 'package:bus49/models/bus_stop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class StopInfo extends StatelessWidget {
  const StopInfo({
    Key? key,
    required this.stop,
    required this.mapController,
  }) : super(key: key);

  final BusStop stop;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    mapController.move(stop.pos, 19);
    return SizedBox(
      height: 100,
      child: Center(child: Text(stop.name + " " + stop.id + " information")),
    );
  }
}
