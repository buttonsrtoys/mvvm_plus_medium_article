import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: incrementCounter,
      child: Text('_counter'),
    );
  }

  int _counter = 0;
  void incrementCounter() => _counter++;
}
