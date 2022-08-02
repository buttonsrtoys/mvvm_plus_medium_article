import 'package:flutter/widgets.dart';

class MyWidget extends StatefulWidget {
  // Start of immutable state
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Start of mutable state
  final message = 'Hello';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Start of UI
  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}