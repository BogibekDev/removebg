import 'package:flutter/material.dart';

class CustomBefore extends StatefulWidget {
  final Widget before;
  final Widget after;
  final double value;
  final ValueChanged<double>? onValueChanged;
  const CustomBefore({ Key? key,
    required this.before,
    required this.after,
    this.value = 0.5,
    this.onValueChanged
  });

  @override
  State<CustomBefore> createState() => _CustomBeforeState();
}

class _CustomBeforeState extends State<CustomBefore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
