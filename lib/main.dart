import 'package:flutter/material.dart';

import 'controller/home.dart';

void main() {
  runApp(MaterialApp(
    title: 'Craps Simulator', // TODO: Localize
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomeRoute(),
    debugShowCheckedModeBanner: false,
  ));
}
