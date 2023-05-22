import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(
    MaterialApp(
        home: const Scaffold(
          body: HomePage(),
        ),
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
        )
    ),
  );
}