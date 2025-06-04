import 'package:flutter/material.dart';

class MainRound extends StatelessWidget {
  final double size;
  final Widget child;

  const MainRound({super.key, required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
        ),
        color: const Color.fromARGB(255, 0, 158, 13),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 8,
            offset: Offset(15, 15),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(padding: const EdgeInsets.all(8.0), child: child),
    );
  }
}
