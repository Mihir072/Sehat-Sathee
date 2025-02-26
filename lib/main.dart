import 'package:flutter/material.dart';
import 'package:sehatsathi/bottombar_scraan/bottom_bar_page.dart';
import 'package:sehatsathi/splash%20page/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sehat Sathi',
      home: BottomBarPage(),
    );
  }
}
