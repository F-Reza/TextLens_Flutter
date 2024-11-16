import 'package:flutter/material.dart';

import 'image_to_text_converter.dart';
//E35070
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
      title: 'TextLens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: ImageToTextConverter(),
    );
  }
}
