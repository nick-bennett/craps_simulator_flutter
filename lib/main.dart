import 'package:flutter/material.dart';

import 'controller/home.dart';

void main() {
  runApp(CrapsSimulatorApp());
}

class CrapsSimulatorApp extends MaterialApp {
  CrapsSimulatorApp({Key? key}) : super(
    key: key,
    title: 'Craps Simulator', // TODO: Localize
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const Home(),
    debugShowCheckedModeBanner: false,
  );
}
