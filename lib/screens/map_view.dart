import 'dart:async';

import 'package:bus49/models/bus.dart';
import 'package:bus49/models/map_data.dart';
import 'package:bus49/services/passiogo.dart';
import 'package:bus49/widgets/app_map.dart';
import 'package:bus49/widgets/bus_list.dart';
import 'package:bus49/widgets/label_icon_button.dart';
import 'package:bus49/widgets/route_selector.dart';
import 'package:bus49/widgets/stop_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late Future<MapData> _mapData;
  late MapController _mapController;
  late Timer _dataUpdateTimer;

  @override
  void initState() {
    _mapController = MapController();
    _mapData = fetchMapData();
    _mapData.then((mapData) {
      _dataUpdateTimer =
          Timer.periodic(const Duration(seconds: 4), (timer) async {
        List<Bus> newBusData = await fetchBusData(mapData.routes);
        // TODO: figure out how to update StopEtas for each stop
        setState(() {
          mapData.buses = newBusData;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _dataUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MapData>(
      future: _mapData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: AppMap(
              mapData: snapshot.requireData,
              mapController: _mapController,
            ),
            bottomNavigationBar: Container(
              height: 60,
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LabelIconButton(
                    iconData: Icons.route,
                    color: Colors.white,
                    labelText: "Routes",
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => RouteSelector(
                                mapData: snapshot.requireData,
                                enableRoute: (idx, value) => setState(() {
                                  snapshot.requireData.routes[idx].enabled =
                                      value;
                                }),
                              ));
                    },
                  ),
                  LabelIconButton(
                    iconData: Icons.stop_circle,
                    color: Colors.white,
                    labelText: "Stops",
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => StopList(
                                mapController: _mapController,
                                mapData: snapshot.requireData,
                              ));
                    },
                  ),
                  LabelIconButton(
                    iconData: Icons.directions_bus,
                    color: Colors.white,
                    labelText: "Buses",
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              BusList(buses: snapshot.requireData.buses));
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
