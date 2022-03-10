import 'package:bus49/models/bus_route.dart';
import 'package:bus49/models/bus_stop.dart';
import 'package:bus49/models/map_data.dart';
import 'package:bus49/widgets/stop_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class StopList extends StatelessWidget {
  const StopList({Key? key, required this.mapData, required this.mapController})
      : super(key: key);

  final MapData mapData;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    // TODO: figure out good way to get/list stops and avoid route duplicates
    // TODO: display which route stop is a part of
    List<BusStop> stops = [];
    for (BusRoute route in mapData.routes) {
      if (route.enabled) {
        for (BusStop stop in route.stops) {
          if (!stops.contains(stop)) {
            stops.add(stop);
          }
        }
      }
    }

    if (stops.isEmpty) {
      return const Center(
          child: Text("No stops to list. Try enabling a route."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stops.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(stops[i].name),
          onTap: () {
            Navigator.pop(context);
            showModalBottomSheet(
                context: context,
                builder: (context) => StopInfo(
                    mapController: mapController,
                    stop: stops[i],
                    etas: mapData.etas.where((element) => true)));
          },
        );
      },
    );
  }
}
