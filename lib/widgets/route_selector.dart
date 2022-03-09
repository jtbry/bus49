import 'package:bus49/models/map_data.dart';
import 'package:flutter/material.dart';

class RouteSelector extends StatefulWidget {
  const RouteSelector({
    Key? key,
    required this.mapData,
    required this.enableRoute,
  }) : super(key: key);

  final MapData mapData;
  final Function(int, bool) enableRoute;

  @override
  State<RouteSelector> createState() => _RouteSelectorState();
}

class _RouteSelectorState extends State<RouteSelector> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.mapData.routes.length,
      itemBuilder: (context, i) {
        return SwitchListTile(
          title: Text(widget.mapData.routes[i].name),
          value: widget.mapData.routes[i].enabled,
          onChanged: (value) {
            setState(() {
              widget.enableRoute(i, value);
            });
          },
          activeColor: widget.mapData.routes[i].color,
        );
      },
    );
  }
}
