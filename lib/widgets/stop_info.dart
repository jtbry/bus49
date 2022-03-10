import 'package:bus49/models/bus_stop.dart';
import 'package:bus49/models/stop_eta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class StopInfo extends StatelessWidget {
  const StopInfo({
    Key? key,
    required this.stop,
    required this.etas,
    required this.mapController,
  }) : super(key: key);

  final BusStop stop;
  final Iterable<StopEta> etas;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    mapController.move(stop.pos, 19);
    return SizedBox(
      child: Center(
          child: ListView.builder(
              itemCount: stop.routes.length,
              itemBuilder: (ctx, i) => ListTile(
                    title: Text(stop.routes[i].name),
                  ))),
    );
  }
}
