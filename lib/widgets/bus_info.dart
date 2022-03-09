import 'package:bus49/models/bus.dart';
import 'package:flutter/material.dart';

class BusInfo extends StatelessWidget {
  const BusInfo({
    Key? key,
    required this.bus,
  }) : super(key: key);

  final Bus bus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(child: Text('Bus ${bus.busId} information')),
    );
  }
}
