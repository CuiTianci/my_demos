import 'package:flutter/material.dart';
import 'package:my_demos/config/my_pages.dart';
import 'package:my_demos/pages/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Demos',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.white,
      ),
      routes: kRoutingMap,
    );
  }
}
