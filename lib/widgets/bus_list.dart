import 'package:bus49/models/bus.dart';
import 'package:bus49/widgets/bus_info.dart';
import 'package:flutter/material.dart';

class BusList extends StatelessWidget {
  const BusList({Key? key, required this.buses}) : super(key: key);

  final List<Bus> buses;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: buses.length,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text('Bus ${buses[i].busId} - ${buses[i].route.name}'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                  context: context,
                  builder: (context) => BusInfo(bus: buses[i]));
            },
          );
        });
  }
}
