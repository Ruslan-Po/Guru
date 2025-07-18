import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:glossy/glossy.dart';

class MainRound extends StatelessWidget {
  final double size;
  final Widget child;

  const MainRound({super.key, required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GlossyContainer(
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(150),
          border: Border.all(
            color: const Color.fromARGB(103, 0, 0, 0),
            width: 0.4,
          ),
          gradient: GlossyLinearGradient(
            colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF4D574E)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            opacity: 0.2,
          ),
          //blendMode: BlendMode.overlay,
          child: Center(
            child: Padding(padding: const EdgeInsets.all(16.0), child: child),
          ),
        ),
      ],
    );
  }
}
