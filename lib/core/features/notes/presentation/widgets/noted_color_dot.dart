import 'package:flutter/material.dart';

final class NotedColorDot extends StatelessWidget {
  const NotedColorDot({super.key, required this.color});

  final Color color;

  static const double _size = 10;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size,
      width: _size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
