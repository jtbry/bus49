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

  @override
  void initState() {
    stopEtas = fetchStopEtas(widget.stop.pureId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StopEta>>(
      future: stopEtas,
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.requireData.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    '${snapshot.requireData[index].eta} - ${snapshot.requireData[index].busId}'),
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
