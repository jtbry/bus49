import 'package:bus49/map_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
      primarySwatch: Colors.green,
    );

    return MaterialApp(
      title: 'bus49',
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('bus49'),
          ),
        ),
        body: const MapView(),
      ),
      theme: theme,
    );
  }
}
