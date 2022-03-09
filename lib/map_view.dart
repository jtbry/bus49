import 'dart:async';
import 'package:bus49/label_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:bus49/passiogo.dart';
import 'package:flutter_map/flutter_map.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late Future<MapData> _mapData;
  late MapController _mapController;
  late Timer _busUpdateTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mapData = fetchMapData();
    _busUpdateTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      setState(() {
        _mapData
            .then((data) async => data.buses = await fetchBusData(data.routes));
      });
    });
  }

  @override
  void dispose() {
    _busUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MapData>(
      future: _mapData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: _buildMap(snapshot.data),
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
                          builder: (context) =>
                              _routeSelectorWidget(snapshot.data));
                    },
                  ),
                  LabelIconButton(
                    iconData: Icons.stop_circle,
                    color: Colors.white,
                    labelText: "Stops",
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => _stopListWidget(snapshot.data));
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
                              _busListWidget(snapshot.data!.buses));
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

  FlutterMap _buildMap(MapData? map) {
    if (map != null) {
      return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: map.center,
          zoom: 15,
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
          PolylineLayerOptions(polylines: map.generatePolylines()),
          MarkerLayerOptions(
              markers:
                  map.generateMarkers((o) => _triggerMarkerInfo(o, context))),
        ],
      );
    } else {
      throw Exception("null MapData in _buildMap");
    }
  }

  Widget _routeSelectorWidget(MapData? data) {
    if (data == null) throw Exception("null MapData in _routeSelectorWidget");
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.routes.length * 2,
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider();
        final idx = i ~/ 2;
        return SwitchListTile(
          title: Text(data.routes[idx].name),
          value: data.routes[idx].enabled,
          onChanged: (value) {
            setState(() {
              // Forcing rebuild through navigator pop and reshowing the sheet
              // TODO: find a better way to do this? make it look more seamless.
              data.routes[idx].enabled = value;
              Navigator.pop(context);
              showModalBottomSheet(
                  context: context,
                  builder: (context) => _routeSelectorWidget(data),
                  transitionAnimationController: null);
            });
          },
          activeColor: data.routes[idx].color,
        );
      },
    );
  }

  Widget _stopListWidget(MapData? data) {
    // TODO: figure out good way to get/list stops and avoid route duplicates
    // TODO: display which route stop is a part of
    if (data == null) throw Exception("null MapData in _stopListWidget");
    List<BusStop> stops = [];
    for (BusRoute route in data.routes) {
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
                builder: (context) => _stopInfoWidget(stops[i]));
          },
        );
      },
    );
  }

  Widget _stopInfoWidget(BusStop stop) {
    _mapController.move(stop.pos, 19);
    return SizedBox(
      height: 100,
      child: Center(child: Text(stop.name + " " + stop.id + " information")),
    );
  }

  Widget _busListWidget(List<Bus> buses) {
    return ListView.builder(
        itemCount: buses.length,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text('Bus ${buses[i].busId} - ${buses[i].route.name}'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                  context: context,
                  builder: (context) => _busInfoWidget(buses[i]));
            },
          );
        });
  }

  Widget _busInfoWidget(Bus bus) {
    return SizedBox(
      height: 100,
      child: Center(child: Text('Bus ${bus.busId} information')),
    );
  }

  void _triggerMarkerInfo(dynamic markerDataObject, BuildContext context) {
    if (markerDataObject is BusStop) {
      showModalBottomSheet(
          context: context,
          builder: (ctx) => _stopInfoWidget(markerDataObject));
    } else if (markerDataObject is Bus) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => _busInfoWidget(markerDataObject),
      );
    }
  }
}
