import 'package:bus49/models/bus_stop.dart';
import 'package:bus49/models/map_data.dart';
import 'package:bus49/widgets/bus_info.dart';
import 'package:bus49/widgets/stop_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/bus.dart';

class AppMap extends StatelessWidget {
  const AppMap({
    Key? key,
    required this.mapData,
    required this.mapController,
  }) : super(key: key);

  final MapData mapData;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: mapData.userLocation ?? mapData.defaultCenter,
        zoom: mapData.userLocation != null ? 17 : 15,
        maxZoom: 18,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return const Text("© OpenStreetMap contributors");
          },
        ),
        PolylineLayerOptions(polylines: mapData.generatePolylines()),
        MarkerLayerOptions(
            markers:
                mapData.generateMarkers((o) => _triggerMarkerInfo(o, context))),
      ],
    );
  }

  void _triggerMarkerInfo(dynamic markerDataObject, BuildContext context) {
    if (markerDataObject is BusStop) {
      showModalBottomSheet(
          context: context,
          builder: (ctx) => StopInfo(
                mapController: mapController,
                stop: markerDataObject,
              ));
    } else if (markerDataObject is Bus) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => BusInfo(bus: markerDataObject),
      );
    }
  }
}
