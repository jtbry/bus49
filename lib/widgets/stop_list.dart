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
    Iterable<BusStop> stops = mapData.stops
        .where((stop) => stop.routes.any((route) => route.enabled));

    if (stops.isEmpty) {
      return const Center(
          child: Text("No stops to list. Try enabling a route."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stops.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(stops.elementAt(i).name),
          onTap: () {
            Navigator.pop(context);
            showModalBottomSheet(
                context: context,
                builder: (context) => StopInfo(
                      mapController: mapController,
                      stop: stops.elementAt(i),
                    ));
          },
        );
      },
    );
  }
}
