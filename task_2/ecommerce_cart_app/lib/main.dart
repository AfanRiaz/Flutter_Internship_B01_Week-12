import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            "APP IS WORKING",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    ),
  );
}