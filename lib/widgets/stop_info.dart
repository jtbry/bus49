import 'dart:async';

import 'package:bus49/models/bus_stop.dart';
import 'package:bus49/models/stop_eta.dart';
import 'package:bus49/services/passiogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class StopInfo extends StatefulWidget {
  const StopInfo({Key? key, required this.stop, required this.mapController})
      : super(key: key);

  final BusStop stop;
  final MapController mapController;

  @override
  State<StopInfo> createState() => _StopInfoState();
}

class _StopInfoState extends State<StopInfo> {
  late Future<List<StopEta>> stopEtas;
  late Timer _etaUpdateTimer;

  @override
  void initState() {
    stopEtas = fetchStopEtas(widget.stop.pureId, widget.stop.routes);
    _etaUpdateTimer = Timer.periodic(
        const Duration(seconds: 4), (timer) => _updateStopInfo());
    super.initState();
  }

  void _updateStopInfo() {
    stopEtas.then((value) async {
      var newEtas = await fetchStopEtas(widget.stop.pureId, widget.stop.routes);
      setState(() {
        value.clear();
        value.addAll(newEtas);
      });
    });
  }

  @override
  void dispose() {
    _etaUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StopEta>>(
      future: stopEtas,
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.requireData.isEmpty) {
            return const Center(
              child: Text('No bus ETAs for this stop.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.requireData.length + 1,
            itemBuilder: (context, index) {
              Text title;
              if (index == 0) {
                title = Text(
                  widget.stop.name,
                  textAlign: TextAlign.center,
                );
              } else {
                index -= 1;
                title = Text(
                    '${snapshot.requireData[index].eta} - ${snapshot.requireData[index].busName} ${snapshot.requireData[index].routeName}');
              }
              return ListTile(
                title: title,
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
